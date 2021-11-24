#! /bin/bash

# shellcheck source=./helper-functions.sh
. /usr/local/bin/helper-functions.sh

LOG_DATE=$(date +"%Y-%m-%d %H:%M:%S ")
_notify 'task' "${LOG_DATE} Start check-for-changes script."

# ? --------------------------------------------- Checks

cd /tmp/docker-mailserver || exit 1

# check postfix-accounts.cf exist else break
if [[ ! -f postfix-accounts.cf ]]
then
  _notify 'inf' "${LOG_DATE} postfix-accounts.cf is missing! This should not run! Exit!"
  exit 0
fi

# verify checksum file exists; must be prepared by start-mailserver.sh
if [[ ! -f ${CHKSUM_FILE} ]]
then
  _notify 'err' "${LOG_DATE} ${CHKSUM_FILE} is missing! Start script failed? Exit!"
  exit 0
fi

# ? --------------------------------------------- Actual script begins

# determine postmaster address, duplicated from start-mailserver.sh
# this script previously didn't work when POSTMASTER_ADDRESS was empty
_obtain_hostname_and_domainname

PM_ADDRESS="${POSTMASTER_ADDRESS:=postmaster@${DOMAINNAME}}"
_notify 'inf' "${LOG_DATE} Using postmaster address ${PM_ADDRESS}"
sleep 10

while true
do
  LOG_DATE=$(date +"%Y-%m-%d %H:%M:%S ")

  # get chksum and check it, no need to lock config yet
  _monitored_files_checksums >"${CHKSUM_FILE}.new"
  cmp --silent -- "${CHKSUM_FILE}" "${CHKSUM_FILE}.new"
  # cmp return codes
  # 0 – files are identical
  # 1 – files differ
  # 2 – inaccessible or missing argument
  if [ $? -eq 1 ]
  then
    _notify 'inf' "${LOG_DATE} Change detected"
    create_lock # Shared config safety lock
    CHANGED=$(grep -Fxvf "${CHKSUM_FILE}" "${CHKSUM_FILE}.new" | sed 's/^[^ ]\+  //')

    # Bug alert! This overwrites the alias set by start-mailserver.sh
    # Take care that changes in one script are propagated to the other

    # ! NEEDS FIX -----------------------------------------
    # TODO FIX --------------------------------------------
    # ! NEEDS EXTENSIONS ----------------------------------
    # TODO Perform updates below conditionally too --------
    # Also note that changes are performed in place and are not atomic
    # We should fix that and write to temporary files, stop, swap and start

    for FILE in ${CHANGED}
    do
      case "${FILE}" in
        "/etc/letsencrypt/acme.json" )
          for CERTDOMAIN in ${SSL_DOMAIN} ${HOSTNAME} ${DOMAINNAME}
          do
            _extract_certs_from_acme "${CERTDOMAIN}" && break
          done
          ;;

        * )
          _notify 'warn' 'File not found for certificate in check_for_changes.sh'
          ;;

      esac
    done

    # regenerate postix aliases
    echo "root: ${PM_ADDRESS}" >/etc/aliases
    if [[ -f /tmp/docker-mailserver/postfix-aliases.cf ]]
    then
      cat /tmp/docker-mailserver/postfix-aliases.cf >>/etc/aliases
    fi
    postalias /etc/aliases

    # regenerate postfix accounts
    : >/etc/postfix/vmailbox
    : >/etc/dovecot/userdb

    if [[ -f /tmp/docker-mailserver/postfix-accounts.cf ]] && [[ ${ENABLE_LDAP} -ne 1 ]]
    then
      sed -i 's/\r//g' /tmp/docker-mailserver/postfix-accounts.cf
      echo "# WARNING: this file is auto-generated. Modify config/postfix-accounts.cf to edit user list." >/etc/postfix/vmailbox

      # Checking that /tmp/docker-mailserver/postfix-accounts.cf ends with a newline
      # shellcheck disable=SC1003
      sed -i -e '$a\' /tmp/docker-mailserver/postfix-accounts.cf
      chown dovecot:dovecot /etc/dovecot/userdb
      chmod 640 /etc/dovecot/userdb
      sed -i -e '/\!include auth-ldap\.conf\.ext/s/^/#/' /etc/dovecot/conf.d/10-auth.conf
      sed -i -e '/\!include auth-passwdfile\.inc/s/^#//' /etc/dovecot/conf.d/10-auth.conf

      # rebuild relay host
      if [[ -n ${RELAY_HOST} ]]
      then
        # keep old config
        : >/etc/postfix/sasl_passwd
        if [[ -n ${SASL_PASSWD} ]]
        then
          echo "${SASL_PASSWD}" >>/etc/postfix/sasl_passwd
        fi

        # add domain-specific auth from config file
        if [[ -f /tmp/docker-mailserver/postfix-sasl-password.cf ]]
        then
          while read -r LINE
          do
            if ! grep -q -e "\s*#" <<< "${LINE}"
            then
              echo "${LINE}" >>/etc/postfix/sasl_passwd
            fi
          done < <(grep -v "^\s*$\|^\s*\#" /tmp/docker-mailserver/postfix-sasl-password.cf || true)
        fi

        # add default relay
        if [[ -n "${RELAY_USER}" ]] && [[ -n "${RELAY_PASSWORD}" ]]
        then
          echo "[${RELAY_HOST}]:${RELAY_PORT}		${RELAY_USER}:${RELAY_PASSWORD}" >>/etc/postfix/sasl_passwd
        fi
      fi

      # creating users ; 'pass' is encrypted
      # comments and empty lines are ignored
      while IFS=$'|' read -r LOGIN PASS USER_ATTRIBUTES
      do
        USER=$(echo "${LOGIN}" | cut -d @ -f1)
        DOMAIN=$(echo "${LOGIN}" | cut -d @ -f2)

        # test if user has a defined quota
        if [[ -f /tmp/docker-mailserver/dovecot-quotas.cf ]]
        then
          declare -a USER_QUOTA
          IFS=':' ; read -r -a USER_QUOTA < <(grep "${USER}@${DOMAIN}:" -i /tmp/docker-mailserver/dovecot-quotas.cf)
          unset IFS

          [[ ${#USER_QUOTA[@]} -eq 2 ]] && USER_ATTRIBUTES="${USER_ATTRIBUTES} userdb_quota_rule=*:bytes=${USER_QUOTA[1]}"
        fi

        echo "${LOGIN} ${DOMAIN}/${USER}/" >>/etc/postfix/vmailbox

        # user database for dovecot has the following format:
        # user:password:uid:gid:(gecos):home:(shell):extra_fields
        # example :
        # ${LOGIN}:${PASS}:5000:5000::/var/mail/${DOMAIN}/${USER}::userdb_mail=maildir:/var/mail/${DOMAIN}/${USER}
        echo "${LOGIN}:${PASS}:5000:5000::/var/mail/${DOMAIN}/${USER}::${USER_ATTRIBUTES}" >>/etc/dovecot/userdb
        mkdir -p "/var/mail/${DOMAIN}/${USER}"

        if [[ -e /tmp/docker-mailserver/${LOGIN}.dovecot.sieve ]]
        then
          cp "/tmp/docker-mailserver/${LOGIN}.dovecot.sieve" "/var/mail/${DOMAIN}/${USER}/.dovecot.sieve"
        fi

        echo "${DOMAIN}" >>/tmp/vhost.tmp
      done < <(grep -v "^\s*$\|^\s*\#" /tmp/docker-mailserver/postfix-accounts.cf)
    fi

    [[ -n ${RELAY_HOST} ]] && _populate_relayhost_map


    if [[ -f /etc/postfix/sasl_passwd ]]
    then
      chown root:root /etc/postfix/sasl_passwd
      chmod 0600 /etc/postfix/sasl_passwd
    fi

    if [[ -f postfix-virtual.cf ]]
    then
      # regenerate postfix aliases
      : >/etc/postfix/virtual
      : >/etc/postfix/regexp

      if [[ -f /tmp/docker-mailserver/postfix-virtual.cf ]]
      then
        cp -f /tmp/docker-mailserver/postfix-virtual.cf /etc/postfix/virtual

        # the `to` seems to be important; don't delete it
        # shellcheck disable=SC2034
        while read -r FROM TO
        do
          UNAME=$(echo "${FROM}" | cut -d @ -f1)
          DOMAIN=$(echo "${FROM}" | cut -d @ -f2)

          # if they are equal it means the line looks like: "user1	 other@domain.tld"
          [ "${UNAME}" != "${DOMAIN}" ] && echo "${DOMAIN}" >>/tmp/vhost.tmp
        done  < <(grep -v "^\s*$\|^\s*\#" /tmp/docker-mailserver/postfix-virtual.cf || true)
      fi

      if [[ -f /tmp/docker-mailserver/postfix-regexp.cf ]]
      then
        cp -f /tmp/docker-mailserver/postfix-regexp.cf /etc/postfix/regexp
        sed -i -e '/^virtual_alias_maps/{
s/ regexp:.*//
s/$/ regexp:\/etc\/postfix\/regexp/
}' /etc/postfix/main.cf
      fi
    fi

    if [[ -f /tmp/vhost.tmp ]]
    then
      sort < /tmp/vhost.tmp | uniq >/etc/postfix/vhost
      rm /tmp/vhost.tmp
    fi

    if find /var/mail -maxdepth 3 -a \( \! -user 5000 -o \! -group 5000 \) | read -r
    then
      chown -R 5000:5000 /var/mail
    fi

    supervisorctl restart postfix

    # prevent restart of dovecot when smtp_only=1
    [[ ${SMTP_ONLY} -ne 1 ]] && supervisorctl restart dovecot

    remove_lock
  fi

  # mark changes as applied
  mv "${CHKSUM_FILE}.new" "${CHKSUM_FILE}"

  sleep 1
done

exit 0
