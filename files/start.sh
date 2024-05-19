#!/usr/bin/env bash
mkdir -p /site/web
mkdir -p /site/logs/php
mkdir -p /site/logs/nginx
mkdir -p /run/php

export PHP_VERSION=${PHP_VERSION:-"7.4"}

export TEMP_CRON_FILE='/site/web/cronFile'
export ENABLE_WEB=${ENABLE_WEB:-"TRUE"}
export CREAT_API_ENV_FILE=${CREAT_API_ENV_FILE:-"TRUE"}
export ENABLE_HORIZON=${ENABLE_HORIZON:-"FALSE"}
export ENABLE_PULSE_CHECK=${ENABLE_PULSE_CHECK:-"FALSE"}
export ENABLE_PULSE_WORK=${ENABLE_PULSE_WORK:-"FALSE"}
export ENABLE_WEBSOCKET=${ENABLE_WEBSOCKET:-"FALSE"}
export LARAVEL_WEBSOCKETS_PORT=${LARAVEL_WEBSOCKETS_PORT:-"2096"}
export ENABLE_SIMPLE_QUEUE=${ENABLE_SIMPLE_QUEUE:-"FALSE"}
export SIMPLE_WORKER_NUM=${SIMPLE_WORKER_NUM:-"5"}
export CRONTAB_ACTIVE=${CRONTAB_ACTIVE:-"FALSE"}
export ENABLE_CRONTAB=${ENABLE_CRONTAB:-${CRONTAB_ACTIVE}}
export ENABLE_DEBUG=${ENABLE_DEBUG:-"FALSE"}
export GEN_LV_ENV=${GEN_LV_ENV:-"FALSE"}
export INITIALISE_FILE=${INITIALISE_FILE:-"/site/web/initialise.sh"}
export LV_DO_CACHING=${LV_DO_CACHING:-"FALSE"}
export ENABLE_SSH=${ENABLE_SSH:-"FALSE"}

export PHP_ERROR_LOG=${PHP_ERROR_LOG:-"/proc/self/fd/2"}
export PHP_ACCESS_LOG=${PHP_ACCESS_LOG:-"/proc/self/fd/2"}
export PHP_IDENT=${PHP_IDENT:-"php"}
export PHP_FPM_IDENT=${PHP_FPM_IDENT:-"php-fpm"}

export PHP_TIMEZONE=${PHP_TIMEZONE:-"UTC"}
export PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:-"128M"}
export PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:-"128M"}
export PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-"3G"}
export PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME:-"600"}
export PHP_MAX_INPUT_TIME=${PHP_MAX_INPUT_TIME:-"600"}
export PHP_SERIAL_PRECISION=${PHP_SERIAL_PRECISION:-${PHP_SERIAL_PRECISION:-"-1"}}
export PHP_PRECISION=${PHP_PRECISION:-${PHP_PRECISION:-"-1"}}
export PHP_DEFAULT_SOCKET_TIMEOUT=${PHP_DEFAULT_SOCKET_TIMEOUT:-"600"}
export PHP_OPCACHE_MEMORY_CONSUMPTION=${PHP_OPCACHE_MEMORY_CONSUMPTION:-"512"}
export PHP_OPCACHE_JIT_BUFFER_SIZE=${PHP_OPCACHE_JIT_BUFFER_SIZE:-"256M"}
export PHP_OPCACHE_JIT=${PHP_OPCACHE_JIT:-"1205"}
export PHP_OPCACHE_INTERNED_STRINGS_BUFFER=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER:-"64"}
export PHP_OPCACHE_MAX_ACCELERATED_FILES=${PHP_OPCACHE_MAX_ACCELERATED_FILES:-"65407"}
export PHP_OPCACHE_REVALIDATE_PATH=${PHP_OPCACHE_REVALIDATE_PATH:-"1"}
export PHP_OPCACHE_ENABLE_FILE_OVERRIDE=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE:-"0"}
export PHP_OPCACHE_VALIDATE_TIMESTAMPS=${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-"1"}
export PHP_OPCACHE_REVALIDATE_FREQ=${PHP_OPCACHE_REVALIDATE_FREQ:-"0"}

export FPM_TIMEOUT=${FPM_TIMEOUT:-600}
export FPM_LISTEN_BACKLOG=${FPM_LISTEN_BACKLOG:-1024}
export FPM_MAX_CHILDREN=${FPM_MAX_CHILDREN:-32}
export FPM_START_SERVERS=${FPM_START_SERVERS:-4}
export FPM_MIN_SPARE_SERVERS=${FPM_MIN_SPARE_SERVERS:-4}
export FPM_MAX_SPARE_SERVERS=${FPM_MAX_SPARE_SERVERS:-8}
export FPM_MAX_REQUESTS=${FPM_MAX_REQUESTS:-1000}

cp /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/cli/php.ini.bak.run
cp /etc/php/${PHP_VERSION}/fpm/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini.bak.run

sed -Ei \
  -e "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
  -e "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/"  \
  -e "s@date.timezone =.*@date.timezone = ${PHP_TIMEZONE}@" \
  -e "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" \
  -e "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" \
  -e "s/max_input_time = .*/max_input_time = ${PHP_MAX_INPUT_TIME}/" \
  -e "s/default_socket_timeout = .*/default_socket_timeout = ${PHP_DEFAULT_SOCKET_TIMEOUT}/" \
  -e "s/serialize_precision.*/serialize_precision = ${PHP_SERIAL_PRECISION}/" \
  -e "s/precision.*/precision = ${PHP_PRECISION}/" \
  -e "s#^error_log = .*#error_log = ${PHP_ERROR_LOG}#" \
  -e "s#^syslog.ident = .*#syslog.ident = ${PHP_IDENT}#" \
  -e "s/opcache.memory_consumption=.*/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/" \
  -e "s/opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER}/" \
  -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}/" \
  -e "s/opcache.revalidate_path=.*/opcache.revalidate_path=${PHP_OPCACHE_REVALIDATE_PATH}/" \
  -e "s/opcache.enable_file_override=.*/opcache.enable_file_override=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE}/" \
  -e "s/opcache.validate_timestamps=.*/opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}/" \
  -e "s/opcache.revalidate_freq=.*/opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ}/" \
  "/etc/php/${PHP_VERSION}/cli/php.ini" \
  "/etc/php/${PHP_VERSION}/fpm/php.ini"

sed -Ei \
  -e "s#^(;|)access.log = .*#access.log = ${PHP_ACCESS_LOG}#" \
  -e "s/^(;|)syslog\.ident = .*/syslog.ident = ${PHP_FPM_IDENT}/" \
  -e "s/^(;|)listen\.backlog.*/listen.backlog = ${FPM_LISTEN_BACKLOG}/" \
  -e "s/^(;|)pm\.max_children = .*/pm.max_children = ${FPM_MAX_CHILDREN}/" \
  -e "s/^(;|)pm\.start_servers = .*/pm.start_servers = ${FPM_START_SERVERS}/" \
  -e "s/^(;|)pm\.min_spare_servers = .*/pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}/" \
  -e "s/^(;|)pm\.max_spare_servers = .*/pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}/" \
  -e "s/^(;|)pm\.max_requests = .*/pm.max_requests = ${FPM_MAX_REQUESTS}/" \
  -e "s#^(;|)request_terminate_timeout = .*#request_terminate_timeout = ${FPM_TIMEOUT}#" \
  -e "s/^listen\.backlog.*/listen.backlog = ${FPM_LISTEN_BACKLOG}/" \
  -e "s/^(;|)clear_env = .*/clear_env = no/" \
  "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

cp /supervisord_base.conf /supervisord.conf

if [[ "${ENABLE_WEB}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_WEB$/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=ENABLE_WEB$/numprocs=0/' /supervisord.conf
fi

if [[ "${ENABLE_HORIZON}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_HORIZON$/numprocs=1/' /supervisord.conf
  SIMPLE_WORKER_NUM='0'
  ENABLE_SIMPLE_QUEUE='FALSE'
else
  sed -E -i -e 's/^numprocs=ENABLE_HORIZON$/numprocs=0/' /supervisord.conf
fi

sed -E -i -e 's/^numprocs=WORKER_NUM$/numprocs='"${WORKERS}"'/' /supervisord.conf

if [[ "${ENABLE_HORIZON}" != "TRUE" && "${ENABLE_SIMPLE_QUEUE}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=SIMPLE_WORKER_NUM$/numprocs='"${SIMPLE_WORKER_NUM}"'/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=SIMPLE_WORKER_NUM$/numprocs=0/' /supervisord.conf
fi

if [[ "${ENABLE_PULSE_WORK}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_PULSE_WORK/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=ENABLE_PULSE_WORK/numprocs=0/' /supervisord.conf
fi

if [[ "${ENABLE_PULSE_CHECK}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_PULSE_CHECK/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=ENABLE_PULSE_CHECK/numprocs=0/' /supervisord.conf
fi

if [[ "${ENABLE_WEBSOCKET}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_WEBSOCKET$/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=ENABLE_WEBSOCKET$/numprocs=0/' /supervisord.conf
fi

sed -E -i -e "s#LARAVEL_WEBSOCKETS_PORT#${LARAVEL_WEBSOCKETS_PORT}#" /supervisord.conf

if [[ "${ENABLE_SSH}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_SSH$/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=ENABLE_SSH$/numprocs=0/' /supervisord.conf
fi

mkdir -p /root/.ssh
mkdir -p /site/.ssh

if [[ ! -z "${SSH_AUTHORIZED_KEYS}" ]];then
  mkdir -p /root/.ssh
  echo "${SSH_AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys
  chown -R root:root /root/.ssh

  mkdir -p /site/.ssh
  chown -R web:web /site/.ssh
  chmod 700 /site/.ssh
  echo "${SSH_AUTHORIZED_KEYS}" > /site/.ssh/authorized_keys
  chmod 600 /site/.ssh/authorized_keys
fi

chmod 700 /root/.ssh
chown root: /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

cat > ${TEMP_CRON_FILE} <<- EndOfMessage
MAILTO=""
# m h  dom mon dow   command
0 * * * * /usr/sbin/logrotate -vf /etc/logrotate.d/*.auto > /proc/\$(cat /var/run/crond.pid)/fd/1 2>&1 >> /dev/stdout

#rename on start
@reboot find /site/web/.envDocker -not -user web -execdir chown "web:" {} \+  > /proc/\$(cat /var/run/crond.pid)/fd/1 2>&1 >> /dev/stdout
@reboot sleep 5 && find /site -not -user web -execdir chown "web:" {} \+  > /proc/\$(cat /var/run/crond.pid)/fd/1 2>&1 >> /dev/stdout

EndOfMessage

if [[ "${ENABLE_CRONTAB}" = "TRUE" ]]; then
 cat >> ${TEMP_CRON_FILE} <<- EndOfMessage
* * * * * su web -c '/usr/bin/php /site/web/artisan schedule:run'  > /proc/\$(cat /var/run/crond.pid)/fd/1 2>&1 >> /dev/stdout
EndOfMessage
fi

crontab - < ${TEMP_CRON_FILE}

rm ${TEMP_CRON_FILE}

sed -E -i -e "s/PHP_VERSION/${PHP_VERSION}/g" /supervisord.conf

if [[ "${ENABLE_DEBUG}" = "TRUE" ]]; then
  phpenmod -v "${PHP_VERSION}" xdebug
  phpenmod -v "${PHP_VERSION}" pcov
else
  phpdismod -v "${PHP_VERSION}" xdebug
  phpdismod -v "${PHP_VERSION}" pcov
fi

if [[ "${GEN_LV_ENV}" = "TRUE" ]]; then
  env | grep 'LVENV_' | sort | sed -E -e 's/"/\\"/g' -e 's#LVENV_(.*)=#\1=#' -e 's#=(.+)#="\1"#' > /site/web/.envDocker
  if [[ "${CREAT_API_ENV_FILE}" = "TRUE" ]]; then
    cp -f /site/web/.envDocker /site/web/.env
  fi
fi

# Try to fix rsyslogd: file '/dev/stdout': open error: Permission denied
chmod -R a+w /dev/stdout
chmod -R a+w /dev/stderr
chmod -R a+w /dev/stdin

#Background to speed up start
find /site -not -user web -execdir chown "web:" {} \+ &

if [[ -e "${INITIALISE_FILE}" ]]; then
  mkdir -p /root/.composer
  chown web: "${INITIALISE_FILE}"
  chmod u+x "${INITIALISE_FILE}"
  chmod a+r /root/.composer
  su web --preserve-environment -c "${INITIALISE_FILE}" >> /dev/stdout
fi

sed -Ei \
  -e "s/NGINX_SITES/${NGINX_SITES}/" \
  /site/nginx/config/sites.conf

sed -Ei \
  -e "s/LARAVEL_WEBSOCKETS_PORT/${LARAVEL_WEBSOCKETS_PORT}/" \
  /site/nginx/config/sites.conf

## Rotate logs at start just in case
/usr/sbin/logrotate -vf /etc/logrotate.d/*.auto &

/usr/bin/supervisord -n -c /supervisord.conf
