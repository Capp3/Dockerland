#! /bin/bash

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

NAME=${NAME:-mailserver-testing:ci}

# default timeout is 120 seconds
TEST_TIMEOUT_IN_SECONDS=${TEST_TIMEOUT_IN_SECONDS-120}
NUMBER_OF_LOG_LINES=${NUMBER_OF_LOG_LINES-10}

# @param ${1} timeout
# @param --fatal-test <command eval string> additional test whose failure aborts immediately
# @param ... test to run
function repeat_until_success_or_timeout {
    local FATAL_FAILURE_TEST_COMMAND
    if [[ "${1}" == "--fatal-test" ]]; then
        FATAL_FAILURE_TEST_COMMAND="${2}"
        shift 2
    fi
    if ! [[ "${1}" =~ ^[0-9]+$ ]]; then
        echo "First parameter for timeout must be an integer, recieved \"${1}\""
        return 1
    fi
    local TIMEOUT=${1}
    local STARTTIME=${SECONDS}
    shift 1
    until "${@}"
    do
        if [[ -n ${FATAL_FAILURE_TEST_COMMAND} ]] && ! eval "${FATAL_FAILURE_TEST_COMMAND}"; then
            echo "\`${FATAL_FAILURE_TEST_COMMAND}\` failed, early aborting repeat_until_success of \`${*}\`" >&2
            return 1
        fi
        sleep 1
        if [[ $(( SECONDS - STARTTIME )) -gt ${TIMEOUT} ]]; then
            echo "Timed out on command: ${*}" >&2
            return 1
        fi
    done
}

# like repeat_until_success_or_timeout but with wrapping the command to run into `run` for later bats consumption
# @param ${1} timeout
# @param ... test command to run
function run_until_success_or_timeout {
    if ! [[ ${1} =~ ^[0-9]+$ ]]; then
        echo "First parameter for timeout must be an integer, recieved \"${1}\""
        return 1
    fi
    local TIMEOUT=${1}
    local STARTTIME=${SECONDS}
    shift 1
    until run "${@}" && [[ $status -eq 0 ]]
    do
        sleep 1
        if (( SECONDS - STARTTIME > TIMEOUT )); then
            echo "Timed out on command: ${*}" >&2
            return 1
        fi
    done
}

# @param ${1} timeout
# @param ${2} container name
# @param ... test command for container
function repeat_in_container_until_success_or_timeout() {
    local TIMEOUT="${1}"
    local CONTAINER_NAME="${2}"
    shift 2
    repeat_until_success_or_timeout --fatal-test "container_is_running ${CONTAINER_NAME}" "${TIMEOUT}" docker exec "${CONTAINER_NAME}" "${@}"
}

function container_is_running() {
    [[ "$(docker inspect -f '{{.State.Running}}' "${1}")" == "true" ]]
}

# @param ${1} port
# @param ${2} container name
function wait_for_tcp_port_in_container() {
    repeat_until_success_or_timeout --fatal-test "container_is_running ${2}" "${TEST_TIMEOUT_IN_SECONDS}" docker exec "${2}" /bin/sh -c "nc -z 0.0.0.0 ${1}"
}

# @param ${1} name of the postfix container
function wait_for_smtp_port_in_container() {
    wait_for_tcp_port_in_container 25 "${1}"
}

# @param ${1} name of the postfix container
function wait_for_smtp_port_in_container_to_respond() {
  local COUNT=0
  until [[ $(docker exec "${1}" timeout 10 /bin/sh -c "echo QUIT | nc localhost 25") == *"221 2.0.0 Bye"* ]]; do
    if [[ $COUNT -eq 20 ]]
    then
      echo "Unable to receive a valid response from 'nc localhost 25' within 20 seconds"
      return 1
    fi
    sleep 1
    ((COUNT+=1))
  done
}

# @param ${1} name of the postfix container
function wait_for_amavis_port_in_container() {
    wait_for_tcp_port_in_container 10024 "${1}"
}

# TODO: Should also fail early on "docker logs ${1} | egrep '^[  FATAL  ]'"?
# @param ${1} name of the postfix container
function wait_for_finished_setup_in_container() {
    local STATUS=0
    repeat_until_success_or_timeout --fatal-test "container_is_running ${1}" "${TEST_TIMEOUT_IN_SECONDS}" sh -c "docker logs ${1} | grep 'is up and running'" || STATUS=1
    if [[ ${STATUS} -eq 1 ]]; then
        echo "Last ${NUMBER_OF_LOG_LINES} lines of container \`${1}\`'s log"
        docker logs "${1}" | tail -n "${NUMBER_OF_LOG_LINES}"
    fi
    return ${STATUS}
}

SETUP_FILE_MARKER="${BATS_TMPDIR}/$(basename "${BATS_TEST_FILENAME}").setup_file"

function native_setup_teardown_file_support() {
    local VERSION_REGEX='([0-9]+)\.([0-9]+)\.([0-9]+)'
    # bats versions that support setup_file out of the box don't need this
    if [[ "${BATS_VERSION}" =~ ${VERSION_REGEX} ]]; then
        numeric_version=$(( (BASH_REMATCH[1] * 100 + BASH_REMATCH[2]) * 100 + BASH_REMATCH[3] ))
        if [[ ${numeric_version} -ge 10201 ]]; then
            if [ "${BATS_TEST_NAME}" == 'test_first' ]; then
                skip 'This version natively supports setup/teardown_file'
            fi
            return 0
        fi
    fi
    return 1
}

# use in setup() in conjunction with a `@test "first" {}` to trigger setup_file reliably
function run_setup_file_if_necessary() {
    native_setup_teardown_file_support && return 0
    if [ "${BATS_TEST_NAME}" == 'test_first' ]; then
        # prevent old markers from marking success or get an error if we cannot remove due to permissions
        rm -f "${SETUP_FILE_MARKER}"

        setup_file

        touch "${SETUP_FILE_MARKER}"
    else
        if [ ! -f "${SETUP_FILE_MARKER}" ]; then
            skip "setup_file failed"
            return 1
        fi
    fi
}

# use in teardown() in conjunction with a `@test "last" {}` to trigger teardown_file reliably
function run_teardown_file_if_necessary() {
    native_setup_teardown_file_support && return 0
    if [ "${BATS_TEST_NAME}" == 'test_last' ]; then
        # cleanup setup file marker
        rm -f "${SETUP_FILE_MARKER}"
        teardown_file
    fi
}

# get the private config path for the given container or test file, if no container name was given
function private_config_path() {
    echo "${PWD}/test/duplicate_configs/${1:-$(basename "${BATS_TEST_FILENAME}")}"
}

# @param ${1} relative source in test/config folder
# @param ${2} (optional) container name, defaults to ${BATS_TEST_FILENAME}
# @return path to the folder where the config is duplicated
function duplicate_config_for_container() {
    local OUTPUT_FOLDER
    OUTPUT_FOLDER="$(private_config_path "${2}")"  || return $?
    rm -rf "${OUTPUT_FOLDER:?}/" || return $? # cleanup
    mkdir -p "${OUTPUT_FOLDER}" || return $?
    cp -r "${PWD}/test/config/${1:?}/." "${OUTPUT_FOLDER}" || return $?
    echo "${OUTPUT_FOLDER}"
}

function container_has_service_running() {
    local CONTAINER_NAME="${1}"
    local SERVICE_NAME="${2}"
    docker exec "${CONTAINER_NAME}" /usr/bin/supervisorctl status "${SERVICE_NAME}" | grep RUNNING >/dev/null
}

function wait_for_service() {
    local CONTAINER_NAME="${1}"
    local SERVICE_NAME="${2}"
    repeat_until_success_or_timeout --fatal-test "container_is_running ${CONTAINER_NAME}" "${TEST_TIMEOUT_IN_SECONDS}" \
        container_has_service_running "${CONTAINER_NAME}" "${SERVICE_NAME}"
}

function wait_for_changes_to_be_detected_in_container() {
    local CONTAINER_NAME="${1}"
    local TIMEOUT=${TEST_TIMEOUT_IN_SECONDS}

    # shellcheck disable=SC2016
    repeat_in_container_until_success_or_timeout "${TIMEOUT}" "${CONTAINER_NAME}" bash -c 'source /usr/local/bin/helper-functions.sh; cmp --silent -- <(_monitored_files_checksums) "${CHKSUM_FILE}" >/dev/null'
}

function wait_for_empty_mail_queue_in_container() {
    local CONTAINER_NAME="${1}"
    local TIMEOUT=${TEST_TIMEOUT_IN_SECONDS}

    # shellcheck disable=SC2016
    repeat_in_container_until_success_or_timeout "${TIMEOUT}" "${CONTAINER_NAME}" bash -c '[[ $(mailq) == *"Mail queue is empty"* ]]'
}

# Common defaults appropriate for most tests, override vars in each test when necessary.
# TODO: Check how many tests need write access. Consider using `docker create` + `docker cp` for easier cleanup.
function init_with_defaults() {
  # Ignore absolute dir path and file extension, only extract filename:
  export TEST_NAME
  TEST_NAME="$(basename "${BATS_TEST_FILENAME}" '.bats')"

  export PRIVATE_CONFIG
  PRIVATE_CONFIG="$(duplicate_config_for_container . "${TEST_NAME}")"
  export TEST_FILES_VOLUME="${PWD}/test/test-files:/tmp/docker-mailserver-test:ro"
  export TEST_CONFIG_VOLUME="${PRIVATE_CONFIG}:/tmp/docker-mailserver:ro"

  export TEST_FQDN='mail.my-domain.com'
}

# Common docker run command that should satisfy most tests which only modify ENV.
function common_container_setup() {
  local TEST_ENV_FILE=$1

  run docker run -d --name "${TEST_NAME}" \
    --volume "${TEST_FILES_VOLUME}" \
    --volume "${TEST_CONFIG_VOLUME}" \
    --hostname "${TEST_FQDN}" \
    --env-file "${TEST_ENV_FILE}" \
    --tty \
    "${NAME}"
  assert_success

  wait_for_finished_setup_in_container "${TEST_NAME}"
}