---
title: Environment Variables
---

!!! info

    Values in **bold** are the default values. If an option doesn't work as documented here, check if you are running the latest image. The current `master` branch corresponds to the image `mailserver/docker-mailserver:edge`.

#### General

##### OVERRIDE_HOSTNAME

- **empty** => uses the `hostname` command to get canonical hostname for `docker-mailserver` to use.
- => Specify a fully-qualified domainname to serve mail for. This is used for many of the config features so if you can't set your hostname (_eg: you're in a container platform that doesn't let you_) specify it via this environment variable. It will take priority over `docker run` options: `--hostname` and `--domainname`, or `docker-compose.yml` config equivalents: `hostname:` and `domainname:`.

##### DMS_DEBUG

- **0** => Debug disabled
- 1     => Enables debug on startup

##### SUPERVISOR_LOGLEVEL

Here you can adjust the [log-level for Supervisor](http://supervisord.org/logging.html#activity-log-levels). Possible values are

- critical => Only show critical messages
- error    => Only show erroneous output
- **warn** => Show warnings
- info     => Normal informational output
- debug    => Also show debug messages

The log-level will show everything in its class and above.

##### ONE_DIR

- 0 => state in default directories.
- **1** => consolidate all states into a single directory (`/var/mail-state`) to allow persistence using docker volumes. See the [related FAQ entry][docs-faq-onedir] for more information.

##### PERMIT_DOCKER

Set different options for mynetworks option (can be overwrite in postfix-main.cf) **WARNING**: Adding the docker network's gateway to the list of trusted hosts, e.g. using the `network` or `connected-networks` option, can create an [**open relay**](https://en.wikipedia.org/wiki/Open_mail_relay), for instance if IPv6 is enabled on the host machine but not in Docker.

- **empty** => localhost only.
- host => Add docker host (ipv4 only).
- network => Add the docker default bridge network (172.16.0.0/12); **WARNING**: `docker-compose` might use others (e.g. 192.168.0.0/16) use `PERMIT_DOCKER=connected-networks` in this case.
- connected-networks => Add all connected docker networks (ipv4 only).

Note: you probably want to [set `POSTFIX_INET_PROTOCOLS=ipv4`](#postfix_inet_protocols) to make it work fine with Docker.

##### ENABLE_AMAVIS

Amavis content filter (used for ClamAV & SpamAssassin)

- 0     => Amavis is disabled
- **1** => Amavis is enabled

##### AMAVIS_LOGLEVEL

[This page](https://lists.amavis.org/pipermail/amavis-users/2011-March/000158.html) provides information on Amavis' logging statistics.

- -1/-2/-3 => Only show errors
- **0**    => Show warnings
- 1/2      => Show default informational output
- 3/4/5    => log debug information (very verbose)

##### ENABLE_CLAMAV

- **0** => Clamav is disabled
- 1 => Clamav is enabled

##### ENABLE_POP3

- **empty** => POP3 service disabled
- 1 => Enables POP3 service

##### ENABLE_FAIL2BAN

- **0** => fail2ban service disabled
- 1 => Enables fail2ban service

If you enable Fail2Ban, don't forget to add the following lines to your `docker-compose.yml`:

``` BASH
cap_add:
  - NET_ADMIN
```

Otherwise, `iptables` won't be able to ban IPs.

##### FAIL2BAN_BLOCKTYPE

- **drop**   => drop packet (send NO reply)
- reject => reject packet (send ICMP unreachable)
FAIL2BAN_BLOCKTYPE=drop

##### SMTP_ONLY

- **empty** => all daemons start
- 1 => only launch postfix smtp

##### SSL_TYPE

In the majority of cases, you want `letsencrypt` or `manual`.

`self-signed` can be used for testing SSL until you provide a valid certificate, note that third-parties cannot trust `self-signed` certificates, do not use this type in production. `custom` is a temporary workaround that is not officially supported.

- **empty** => SSL disabled.
- letsencrypt => Support for using certificates with _Let's Encrypt_ provisioners. (Docs: [_Let's Encrypt_ Setup][docs-tls-letsencrypt])
- manual => Provide your own certificate via separate key and cert files. (Docs: [Bring Your Own Certificates][docs-tls-manual])
    - Requires: `SSL_CERT_PATH` and `SSL_KEY_PATH` ENV vars to be set to the location of the files within the container.
    - Optional: `SSL_ALT_CERT_PATH` and `SSL_ALT_KEY_PATH` allow providing a 2nd certificate as a fallback for dual (aka hybrid) certificate support. Useful for ECDSA with an RSA fallback. _Presently only `manual` mode supports this feature_.
- custom => Provide your own certificate as a single file containing both the private key and full certificate chain. (Docs: `None`)
- self-signed => Provide your own self-signed certificate files. Expects a self-signed CA cert for verification. **Use only for local testing of your setup**. (Docs: [Self-Signed Certificates][docs-tls-selfsigned])

Please read [the SSL page in the documentation][docs-tls] for more information.

##### TLS_LEVEL

- **empty** => modern
- modern => Enables TLSv1.2 and modern ciphers only. (default)
- intermediate => Enables TLSv1, TLSv1.1 and TLSv1.2 and broad compatibility ciphers.

##### SPOOF_PROTECTION

Configures the handling of creating mails with forged sender addresses.

- **empty** => Mail address spoofing allowed. Any logged in user may create email messages with a forged sender address. See also [Wikipedia](https://en.wikipedia.org/wiki/Email_spoofing)(not recommended, but default for backwards compatibility reasons)
- 1 => (recommended) Mail spoofing denied. Each user may only send with his own or his alias addresses. Addresses with [extension delimiters](http://www.postfix.org/postconf.5.html#recipient_delimiter) are not able to send messages.

##### ENABLE_SRS

Enables the Sender Rewriting Scheme. SRS is needed if `docker-mailserver` acts as forwarder. See [postsrsd](https://github.com/roehling/postsrsd/blob/master/README.md#sender-rewriting-scheme-crash-course) for further explanation.

- **0** => Disabled
- 1 => Enabled

##### NETWORK_INTERFACE

In case your network interface differs from `eth0`, e.g. when you are using HostNetworking in Kubernetes, you can set this to whatever interface you want. This interface will then be used.

- **empty** => `eth0`

##### VIRUSMAILS_DELETE_DELAY

Set how many days a virusmail will stay on the server before being deleted

- **empty** => 7 days

##### ENABLE_POSTFIX_VIRTUAL_TRANSPORT

This Option is activating the Usage of POSTFIX_DAGENT to specify a ltmp client different from default dovecot socket.

- **empty** => disabled
- 1 => enabled

##### POSTFIX_DAGENT

Enabled by ENABLE_POSTFIX_VIRTUAL_TRANSPORT. Specify the final delivery of postfix

- **empty**: fail
- `lmtp:unix:private/dovecot-lmtp` (use socket)
- `lmtps:inet:<host>:<port>` (secure lmtp with starttls, take a look at <https://sys4.de/en/blog/2014/11/17/sicheres-lmtp-mit-starttls-in-dovecot/>)
- `lmtp:<kopano-host>:2003` (use kopano as mailstore)
- etc.

##### POSTFIX\_MAILBOX\_SIZE\_LIMIT

Set the mailbox size limit for all users. If set to zero, the size will be unlimited (default).

- **empty** => 0 (no limit)

##### ENABLE_QUOTAS

- **1** => Dovecot quota is enabled
- 0 => Dovecot quota is disabled

See [mailbox quota][docs-accounts].

##### POSTFIX\_MESSAGE\_SIZE\_LIMIT

Set the message size limit for all users. If set to zero, the size will be unlimited (not recommended!)

- **empty** => 10240000 (~10 MB)

##### ENABLE_MANAGESIEVE

- **empty** => Managesieve service disabled
- 1 => Enables Managesieve on port 4190

##### POSTMASTER_ADDRESS

- **empty** => postmaster@example.com
- => Specify the postmaster address

##### ENABLE_UPDATE_CHECK

Check for updates on container start and then once a day. If an update is available, a mail is send to POSTMASTER_ADDRESS.

- 0 => Update check disabled
- **1** => Update check enabled

##### UPDATE_CHECK_INTERVAL

Customize the update check interval. Number + Suffix. Suffix must be 's' for seconds, 'm' for minutes, 'h' for hours or 'd' for days.

- **1d** => Check for updates once a day

##### POSTSCREEN_ACTION

- **enforce** => Allow other tests to complete. Reject attempts to deliver mail with a 550 SMTP reply, and log the helo/sender/recipient information. Repeat this test the next time the client connects.
- drop => Drop the connection immediately with a 521 SMTP reply. Repeat this test the next time the client connects.
- ignore => Ignore the failure of this test. Allow other tests to complete. Repeat this test the next time the client connects. This option is useful for testing and collecting statistics without blocking mail.

##### DOVECOT_MAILBOX_FORMAT

- **maildir** => uses very common Maildir format, one file contains one message
- sdbox => (experimental) uses Dovecot high-performance mailbox format, one file contains one message
- mdbox ==> (experimental) uses Dovecot high-performance mailbox format, multiple messages per file and multiple files per box

This option has been added in November 2019. Using other format than Maildir is considered as experimental in docker-mailserver and should only be used for testing purpose. For more details, please refer to [Dovecot Documentation](https://wiki2.dovecot.org/MailboxFormat).

##### POSTFIX_INET_PROTOCOLS

- **all** => All possible protocols.
- ipv4 => Use only IPv4 traffic. Most likely you want this behind Docker.
- ipv6 => Use only IPv6 traffic.

Note: More details in <http://www.postfix.org/postconf.5.html#inet_protocols>

#### Reports

##### PFLOGSUMM_TRIGGER

Enables regular pflogsumm mail reports.

- **not set** => No report
- daily_cron => Daily report for the previous day
- logrotate => Full report based on the mail log when it is rotated

This is a new option. The old REPORT options are still supported for backwards compatibility.
If this is not set and reports are enabled with the old options, logrotate will be used.

##### PFLOGSUMM_RECIPIENT

Recipient address for pflogsumm reports.

- **not set** => Use REPORT_RECIPIENT or POSTMASTER_ADDRESS
- => Specify the recipient address(es)

##### PFLOGSUMM_SENDER

From address for pflogsumm reports.

- **not set** => Use REPORT_SENDER or POSTMASTER_ADDRESS
- => Specify the sender address

##### LOGWATCH_INTERVAL

Interval for logwatch report.

- **none** => No report is generated
- daily => Send a daily report
- weekly => Send a report every week

##### LOGWATCH_RECIPIENT

Recipient address for logwatch reports if they are enabled.

- **not set** => Use REPORT_RECIPIENT or POSTMASTER_ADDRESS
- => Specify the recipient address(es)

##### REPORT_RECIPIENT (deprecated)

Enables a report being sent (created by pflogsumm) on a regular basis.

- **0** => Report emails are disabled unless enabled by other options
- 1 => Using POSTMASTER_ADDRESS as the recipient
- => Specify the recipient address

##### REPORT_SENDER (deprecated)

Change the sending address for mail report

- **empty** => mailserver-report@hostname
- => Specify the report sender (From) address

##### REPORT_INTERVAL (deprecated)

Changes the interval in which logs are rotated and a report is being sent (deprecated).

- **daily** => Send a daily report
- weekly => Send a report every week
- monthly => Send a report every month

Note: This variable used to control logrotate inside the container and sent the pflogsumm report when the logs were rotated.
It is still supported for backwards compatibility, but the new option LOGROTATE_INTERVAL has been added that only rotates
the logs.

##### LOGROTATE_INTERVAL

Defines the interval in which the mail log is being rotated.

- **daily** => Rotate daily.
- weekly => Rotate weekly.
- monthly => Rotate monthly.

Note that only the log inside the container is affected.
The full log output is still available via `docker logs mailserver` (_or your respective container name_).
If you want to control logrotation for the docker generated logfile, see: [Docker Logging Drivers](https://docs.docker.com/config/containers/logging/configure/).

Also note that by default the logs are lost when the container is recycled. To keep the logs, mount a volume.

Finally the logrotate interval **may** affect the period for generated reports. That is the case when the reports are triggered by log rotation.

#### SpamAssassin

##### ENABLE_SPAMASSASSIN

- **0** => SpamAssassin is disabled
- 1 => SpamAssassin is enabled

**/!\\ Spam delivery:** when SpamAssassin is enabled, messages marked as spam WILL NOT BE DELIVERED.
Use `SPAMASSASSIN_SPAM_TO_INBOX=1` for receiving spam messages.

##### SPAMASSASSIN_SPAM_TO_INBOX

- **0** => Spam messages will be bounced (_rejected_) without any notification (_dangerous_).
- 1 => Spam messages will be delivered to the inbox and tagged as spam using `SA_SPAM_SUBJECT`.

##### MOVE_SPAM_TO_JUNK

- **1** => Spam messages will be delivered in the `Junk` folder.
- 0 => Spam messages will be delivered in the mailbox.

Note: this setting needs `SPAMASSASSIN_SPAM_TO_INBOX=1`

##### SA_TAG

- **2.0** => add spam info headers if at, or above that level

Note: this SpamAssassin setting needs `ENABLE_SPAMASSASSIN=1`

##### SA_TAG2

- **6.31** => add 'spam detected' headers at that level

Note: this SpamAssassin setting needs `ENABLE_SPAMASSASSIN=1`

##### SA_KILL

- **6.31** => triggers spam evasive actions

!!! note "This SpamAssassin setting needs `ENABLE_SPAMASSASSIN=1`"

    By default, `docker-mailserver` is configured to quarantine spam emails.
    
    If emails are quarantined, they are compressed and stored in a location dependent on the `ONE_DIR` setting above. To inhibit this behaviour and deliver spam emails, set this to a very high value e.g. `100.0`.

    If `ONE_DIR=1` (default) the location is `/var/mail-state/lib-amavis/virusmails/`, or if `ONE_DIR=0`: `/var/lib/amavis/virusmails/`. These paths are inside the docker container.

##### SA_SPAM_SUBJECT

- **\*\*\*SPAM\*\*\*** => add tag to subject if spam detected

Note: this SpamAssassin setting needs `ENABLE_SPAMASSASSIN=1`. Add the SpamAssassin score to the subject line by inserting the keyword \_SCORE\_: **\*\*\*SPAM(\_SCORE\_)\*\*\***.

##### SA_SHORTCIRCUIT_BAYES_SPAM

- **1** => will activate SpamAssassin short circuiting for bayes spam detection.

This will uncomment the respective line in ```/etc/spamassasin/local.cf```

Note: activate this only if you are confident in your bayes database for identifying spam.

##### SA_SHORTCIRCUIT_BAYES_HAM

- **1** => will activate SpamAssassin short circuiting for bayes ham detection

This will uncomment the respective line in ```/etc/spamassasin/local.cf```

Note: activate this only if you are confident in your bayes database for identifying ham.

#### Fetchmail

##### ENABLE_FETCHMAIL

- **0** => `fetchmail` disabled
- 1 => `fetchmail` enabled

##### FETCHMAIL_POLL

- **300** => `fetchmail` The number of seconds for the interval

##### FETCHMAIL_PARALLEL

  **0** => `fetchmail` runs with a single config file `/etc/fetchmailrc`
  **1** => `/etc/fetchmailrc` is split per poll entry. For every poll entry a seperate fetchmail instance is started  to allow having multiple imap idle configurations defined.

Note: The defaults of your fetchmailrc file need to be at the top of the file. Otherwise it won't be added correctly to all separate `fetchmail` instances.

#### LDAP

##### ENABLE_LDAP

- **empty** => LDAP authentification is disabled
- 1 => LDAP authentification is enabled
- NOTE:
  - A second container for the ldap service is necessary (e.g. [docker-openldap](https://github.com/osixia/docker-openldap))
  - For preparing the ldap server to use in combination with this container [this](http://acidx.net/wordpress/2014/06/installing-a-mailserver-with-postfix-dovecot-sasl-ldap-roundcube/) article may be helpful

##### LDAP_START_TLS

- **empty** => no
- yes => LDAP over TLS enabled for Postfix

##### LDAP_SERVER_HOST

- **empty** => mail.example.com
- => Specify the dns-name/ip-address where the ldap-server is listening, or an URI like `ldaps://mail.example.com`
- NOTE: If you going to use `docker-mailserver` in combination with `docker-compose.yml` you can set the service name here

##### LDAP_SEARCH_BASE

- **empty** => ou=people,dc=domain,dc=com
- => e.g. LDAP_SEARCH_BASE=dc=mydomain,dc=local

##### LDAP_BIND_DN

- **empty** => cn=admin,dc=domain,dc=com
- => take a look at examples of SASL_LDAP_BIND_DN

##### LDAP_BIND_PW

- **empty** => admin
- => Specify the password to bind against ldap

##### LDAP_QUERY_FILTER_USER

- e.g. `(&(mail=%s)(mailEnabled=TRUE))`
- => Specify how ldap should be asked for users

##### LDAP_QUERY_FILTER_GROUP

- e.g. `(&(mailGroupMember=%s)(mailEnabled=TRUE))`
- => Specify how ldap should be asked for groups

##### LDAP_QUERY_FILTER_ALIAS

- e.g. `(&(mailAlias=%s)(mailEnabled=TRUE))`
- => Specify how ldap should be asked for aliases

##### LDAP_QUERY_FILTER_DOMAIN

- e.g. `(&(|(mail=*@%s)(mailalias=*@%s)(mailGroupMember=*@%s))(mailEnabled=TRUE))`
- => Specify how ldap should be asked for domains

##### LDAP_QUERY_FILTER_SENDERS

- **empty**  => use user/alias/group maps directly, equivalent to `(|($LDAP_QUERY_FILTER_USER)($LDAP_QUERY_FILTER_ALIAS)($LDAP_QUERY_FILTER_GROUP))`
- => Override how ldap should be asked if a sender address is allowed for a user

##### DOVECOT_TLS

- **empty** => no
- yes => LDAP over TLS enabled for Dovecot

#### Dovecot

The following variables overwrite the default values for ```/etc/dovecot/dovecot-ldap.conf.ext```.

##### DOVECOT_BASE

- **empty** =>  same as `LDAP_SEARCH_BASE`
- => Tell Dovecot to search only below this base entry. (e.g. `ou=people,dc=domain,dc=com`)

##### DOVECOT_DEFAULT_PASS_SCHEME

- **empty** =>  `SSHA`
- => Select one crypt scheme for password hashing from this list of [password schemes](https://doc.dovecot.org/configuration_manual/authentication/password_schemes/).

##### DOVECOT_DN

- **empty** => same as `LDAP_BIND_DN`
- => Bind dn for LDAP connection. (e.g. `cn=admin,dc=domain,dc=com`)

##### DOVECOT_DNPASS
- **empty** => same as `LDAP_BIND_PW`
- => Password for LDAP dn sepecifified in `DOVECOT_DN`.

##### DOVECOT_URIS

- **empty** => same as `LDAP_SERVER_HOST`
- => Specify a space separated list of LDAP uris.
- Note: If the protocol is missing, `ldap://` will be used.
- Note: This deprecates `DOVECOT_HOSTS` (as it didn't allow to use LDAPS), which is currently still supported for backwards compatibility.

##### DOVECOT_LDAP_VERSION

- **empty** => 3
- 2 => LDAP version 2 is used
- 3 => LDAP version 3 is used

##### DOVECOT_AUTH_BIND

- **empty** => no
- yes => Enable [LDAP authentication binds](https://wiki.dovecot.org/AuthDatabase/LDAP/AuthBinds)

##### DOVECOT_USER_FILTER

- e.g. `(&(objectClass=PostfixBookMailAccount)(uniqueIdentifier=%n))`

##### DOVECOT_USER_ATTRS

- e.g. `homeDirectory=home,qmailUID=uid,qmailGID=gid,mailMessageStore=mail`
- => Specify the directory to dovecot attribute mapping that fits your directory structure.
- Note: This is necessary for directories that do not use the Postfix Book Schema.
- Note: The left-hand value is the directory attribute, the right hand value is the dovecot variable.
- More details on the [Dovecot Wiki](https://wiki.dovecot.org/AuthDatabase/LDAP/Userdb)

##### DOVECOT_PASS_FILTER

- e.g. `(&(objectClass=PostfixBookMailAccount)(uniqueIdentifier=%n))`
- **empty** => same as `DOVECOT_USER_FILTER`

##### DOVECOT_PASS_ATTRS

- e.g. `uid=user,userPassword=password`
- => Specify the directory to dovecot variable mapping that fits your directory structure.
- Note: This is necessary for directories that do not use the Postfix Book Schema.
- Note: The left-hand value is the directory attribute, the right hand value is the dovecot variable.
- More details on the [Dovecot Wiki](https://wiki.dovecot.org/AuthDatabase/LDAP/PasswordLookups)

#### Postgrey

##### ENABLE_POSTGREY

- **0** => `postgrey` is disabled
- 1 => `postgrey` is enabled

##### POSTGREY_DELAY

- **300** => greylist for N seconds

Note: This postgrey setting needs `ENABLE_POSTGREY=1`

##### POSTGREY_MAX_AGE

- **35** => delete entries older than N days since the last time that they have been seen

Note: This postgrey setting needs `ENABLE_POSTGREY=1`

##### POSTGREY_AUTO_WHITELIST_CLIENTS

- **5** => whitelist host after N successful deliveries (N=0 to disable whitelisting)

Note: This postgrey setting needs `ENABLE_POSTGREY=1`

##### POSTGREY_TEXT

- **Delayed by Postgrey** => response when a mail is greylisted

Note: This postgrey setting needs `ENABLE_POSTGREY=1`

#### SASL Auth

##### ENABLE_SASLAUTHD

- **0** => `saslauthd` is disabled
- 1 => `saslauthd` is enabled

##### SASLAUTHD_MECHANISMS

- **empty** => pam
- `ldap` => authenticate against ldap server
- `shadow` => authenticate against local user db
- `mysql` => authenticate against mysql db
- `rimap` => authenticate against imap server
- NOTE: can be a list of mechanisms like pam ldap shadow

##### SASLAUTHD_MECH_OPTIONS

- **empty** => None
- e.g. with SASLAUTHD_MECHANISMS rimap you need to specify the ip-address/servername of the imap server  ==> xxx.xxx.xxx.xxx

##### SASLAUTHD_LDAP_SERVER

- **empty** => same as `LDAP_SERVER_HOST`
- Note: since version 10.0.0, you can specify a protocol here (like ldaps://); this deprecates SASLAUTHD_LDAP_SSL.

##### SASLAUTHD_LDAP_START_TLS

- **empty** => `no`
- `yes` => Enable `ldap_start_tls` option

##### SASLAUTHD_LDAP_TLS_CHECK_PEER

- **empty** => `no`
- `yes` => Enable `ldap_tls_check_peer` option

##### SASLAUTHD_LDAP_TLS_CACERT_DIR

Path to directory with CA (Certificate Authority) certificates.

- **empty** => Nothing is added to the configuration
- Any value => Fills the `ldap_tls_cacert_dir` option

##### SASLAUTHD_LDAP_TLS_CACERT_FILE

File containing CA (Certificate Authority) certificate(s).

- **empty** => Nothing is added to the configuration
- Any value => Fills the `ldap_tls_cacert_file` option

##### SASLAUTHD_LDAP_BIND_DN

- **empty** => same as `LDAP_BIND_DN`
- specify an object with privileges to search the directory tree
- e.g. active directory: SASLAUTHD_LDAP_BIND_DN=cn=Administrator,cn=Users,dc=mydomain,dc=net
- e.g. openldap: SASLAUTHD_LDAP_BIND_DN=cn=admin,dc=mydomain,dc=net

##### SASLAUTHD_LDAP_PASSWORD

- **empty** => same as `LDAP_BIND_PW`

##### SASLAUTHD_LDAP_SEARCH_BASE

- **empty** => same as `LDAP_SEARCH_BASE`
- specify the search base

##### SASLAUTHD_LDAP_FILTER

- **empty** => default filter `(&(uniqueIdentifier=%u)(mailEnabled=TRUE))`
- e.g. for active directory: `(&(sAMAccountName=%U)(objectClass=person))`
- e.g. for openldap: `(&(uid=%U)(objectClass=person))`

##### SASLAUTHD_LDAP_PASSWORD_ATTR

Specify what password attribute to use for password verification.

- **empty** => Nothing is added to the configuration but the documentation says it is `userPassword` by default.
- Any value => Fills the `ldap_password_attr` option

##### SASL_PASSWD

- **empty** => No sasl_passwd will be created
- string => `/etc/postfix/sasl_passwd` will be created with the string as password

##### SASLAUTHD_LDAP_AUTH_METHOD

- **empty** => `bind` will be used as a default value
- `fastbind` => The fastbind method is used
- `custom` => The custom method uses userPassword attribute to verify the password

##### SASLAUTHD_LDAP_MECH

Specify the authentication mechanism for SASL bind.

- **empty** => Nothing is added to the configuration
- Any value => Fills the `ldap_mech` option

#### SRS (Sender Rewriting Scheme)

##### SRS_SENDER_CLASSES

An email has an "envelope" sender (indicating the sending server) and a
"header" sender (indicating who sent it). More strict SPF policies may require
you to replace both instead of just the envelope sender.

[More info](https://www.mybluelinux.com/what-is-email-envelope-and-email-header/).

- **envelope_sender** => Rewrite only envelope sender address
- header_sender => Rewrite only header sender (not recommended)
- envelope_sender,header_sender => Rewrite both senders

##### SRS_EXCLUDE_DOMAINS

- **empty** => Envelope sender will be rewritten for all domains
- provide comma separated list of domains to exclude from rewriting

##### SRS_SECRET

- **empty** => generated when the container is started for the first time
- provide a secret to use in base64
- you may specify multiple keys, comma separated. the first one is used for signing and the remaining will be used for verification. this is how you rotate and expire keys
- if you have a cluster/swarm make sure the same keys are on all nodes
- example command to generate a key: `dd if=/dev/urandom bs=24 count=1 2>/dev/null | base64`

##### SRS_DOMAINNAME

- **empty** => Derived from [`OVERRIDE_HOSTNAME`](#override_hostname), `$DOMAINNAME` (internal), or the container's hostname
- Set this if auto-detection fails, isn't what you want, or you wish to have a separate container handle DSNs

#### Default Relay Host

##### DEFAULT_RELAY_HOST

- **empty** => don't set default relayhost setting in main.cf
- default host and port to relay all mail through.
    Format: `[example.com]:587` (don't forget the brackets if you need this to
    be compatible with `$RELAY_USER` and `$RELAY_PASSWORD`, explained below).

#### Multi-domain Relay Hosts

##### RELAY_HOST

- **empty** => don't configure relay host
- default host to relay mail through

##### RELAY_PORT

- **empty** => 25
- default port to relay mail through

##### RELAY_USER

- **empty** => no default
- default relay username (if no specific entry exists in postfix-sasl-password.cf)

##### RELAY_PASSWORD

- **empty** => no default
- password for default relay user

[docs-faq-onedir]: ../faq.md#what-is-the-mail-state-folder-for
[docs-tls]: ./security/ssl.md
[docs-tls-letsencrypt]: ./security/ssl.md#lets-encrypt-recommended
[docs-tls-manual]: ./security/ssl.md#bring-your-own-certificates
[docs-tls-selfsigned]: ./security/ssl.md#self-signed-certificates
[docs-accounts]: ./user-management/accounts.md#notes
