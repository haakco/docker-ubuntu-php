#!/usr/bin/env bash
mkdir -p /site/web
mkdir -p /site/logs/php
mkdir -p /site/logs/nginx
mkdir -p /site/logs/supervisor
mkdir -p /run/php

export PHP_VERSION=${PHP_VERSION:-"7.4"}

export TEMP_CRON_FILE='/site/web/cronFile'
export ENABLE_HORIZON=${ENABLE_HORIZON:-"FALSE"}
export ENABLE_WEBSOCKET=${ENABLE_WEBSOCKET:-"FALSE"}
export LARAVEL_ECHO_PORT=${LARAVEL_ECHO_PORT:-"6001"}
export ENABLE_SIMPLE_QUEUE=${ENABLE_SIMPLE_QUEUE:-"FALSE"}
export SIMPLE_WORKER_NUM=${SIMPLE_WORKER_NUM:-"5"}
export CRONTAB_ACTIVE=${CRONTAB_ACTIVE:-"FALSE"}
export ENABLE_DEBUG=${ENABLE_DEBUG:-"FALSE"}
export GEN_LV_ENV=${GEN_LV_ENV:-"FALSE"}
export INITIALISE_FILE=${INITIALISE_FILE:-"/site/web/initialise.sh"}
export LV_DO_CACHING=${LV_DO_CACHING:-"FALSE"}
export ENABLE_SSH=${ENABLE_SSH:-"FALSE"}

export PHP_TIMEZONE=${PHP_TIMEZONE:-"Africa/Johannesburg"}
export PHP_UPLOAD_MAX_FILESIZE=${PHP_UPLOAD_MAX_FILESIZE:-"128M"}
export PHP_POST_MAX_SIZE=${PHP_POST_MAX_SIZE:-"128M"}
export PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-"3G"}
export PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME:-"600"}
export PHP_MAX_INPUT_TIME=${PHP_MAX_INPUT_TIME:-"600"}
export PHP_DEFAULT_SOCKET_TIMEOUT=${PHP_DEFAULT_SOCKET_TIMEOUT:-"600"}
export PHP_OPCACHE_MEMORY_CONSUMPTION=${PHP_OPCACHE_MEMORY_CONSUMPTION:-"128"}
export PHP_OPCACHE_INTERNED_STRINGS_BUFFER=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER:-"16"}
export PHP_OPCACHE_MAX_ACCELERATED_FILES=${PHP_OPCACHE_MAX_ACCELERATED_FILES:-"16229"}
export PHP_OPCACHE_REVALIDATE_PATH=${PHP_OPCACHE_REVALIDATE_PATH:-"1"}
export PHP_OPCACHE_ENABLE_FILE_OVERRIDE=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE:-"0"}
export PHP_OPCACHE_VALIDATE_TIMESTAMPS=${PHP_OPCACHE_VALIDATE_TIMESTAMPS:-"1"}
export PHP_OPCACHE_REVALIDATE_FREQ=${PHP_OPCACHE_REVALIDATE_FREQ:-"0"}
export PHP_OPCACHE_PRELOAD_FILE=${PHP_OPCACHE_PRELOAD_FILE:-""}


sed -i \
  -e "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
  -e "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/"  \
  -e "s@date.timezone =.*@date.timezone = ${PHP_TIMEZONE}@" \
  -e "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" \
  -e "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" \
  -e "s/max_input_time = .*/max_input_time = ${PHP_MAX_INPUT_TIME}/" \
  -e "s/default_socket_timeout = .*/default_socket_timeout = ${PHP_DEFAULT_SOCKET_TIMEOUT}/" \
  -e "s/opcache.memory_consumption=.*/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/" \
  -e "s/opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER}/" \
  -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}/" \
  -e "s/opcache.revalidate_path=.*/opcache.revalidate_path=${PHP_OPCACHE_REVALIDATE_PATH}/" \
  -e "s/opcache.enable_file_override=.*/opcache.enable_file_override=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE}/" \
  -e "s/opcache.validate_timestamps=.*/opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}/" \
  -e "s/opcache.revalidate_freq=.*/opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ}/" \
  /etc/php/"${PHP_VERSION}"/cli/php.ini \
  /etc/php/"${PHP_VERSION}"/fpm/php.ini

if [[ "${PHP_OPCACHE_PRELOAD_FILE}" != "" ]]; then
  sed -i \
    -e "s#;opcache.preload=.*#opcache.preload=${PHP_OPCACHE_PRELOAD_FILE}#" \
    -e "s#;opcache.preload_user=.*#opcache.preload_user=web#" \
    /etc/php/"${PHP_VERSION}"/fpm/php.ini
fi

cp /supervisord_base.conf /supervisord.conf

if [[ "${ENABLE_HORIZON}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=ENABLE_HORIZON/numprocs=1/' /supervisord.conf
  SIMPLE_WORKER_NUM='0'
  ENABLE_SIMPLE_QUEUE='FALSE'
else
  sed -E -i -e 's/^numprocs=ENABLE_HORIZON/numprocs=0/' /supervisord.conf
fi

sed -E -i -e 's/^numprocs=WORKER_NUM/numprocs='"${WORKERS}"'/' /supervisord.conf

if [[ "${ENABLE_HORIZON}" != "TRUE" && "${ENABLE_SIMPLE_QUEUE}" = "TRUE" ]]; then
  sed -E -i -e 's/SIMPLE_WORKER_NUM/'"${SIMPLE_WORKER_NUM}"'/' /supervisord.conf
else
  sed -E -i -e 's/SIMPLE_WORKER_NUM/0/' /supervisord.conf
fi

if [[ "${ENABLE_WEBSOCKET}" = "TRUE" ]]; then
  sed -E -i -e 's/^numprocs=WEBSOCKET_NUM/numprocs=1/' /supervisord.conf
else
  sed -E -i -e 's/^numprocs=WEBSOCKET_NUM/numprocs=0/' /supervisord.conf
fi

sed -E -i -e "s#LARAVEL_ECHO_PORT#${LARAVEL_ECHO_PORT}#" /supervisord.conf

if [[ "${ENABLE_SSH}" = "TRUE" ]]; then
  sed -E -i -e 's/ENABLE_SSH/1/' /supervisord.conf
else
  sed -E -i -e 's/ENABLE_SSH/0/' /supervisord.conf
fi

chmod 700 /root/.ssh

if [[ ! -z "${SSH_AUTHORIZED_KEYS}" ]];then
  echo "${SSH_AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
fi

chown root: /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

cat > ${TEMP_CRON_FILE} <<- EndOfMessage
# m h  dom mon dow   command
0 * * * * /usr/sbin/logrotate -vf /etc/logrotate.d/*.auto 2>&1 | /dev/stdout
10 4 * * 6 /usr/bin/geoipupdate -v --config-file /etc/GeoIP.conf -d /usr/share/GeoIP; chown -R web: /usr/share/GeoIP/*

#rename on start
@reboot find /site/web/.env -not -user web -execdir chown "web:" {} \+ 2>&1 | /dev/stdout
@reboot find /site -not -user web -execdir chown "web:" {} \+ | /dev/stdout

EndOfMessage

if [[ "${CRONTAB_ACTIVE}" = "TRUE" ]]; then
 cat >> ${TEMP_CRON_FILE} <<- EndOfMessage
* * * * * su web -c '/usr/bin/php /site/web/artisan schedule:run' 2>&1 >> /site/logs/cron.log
EndOfMessage
fi

cat ${TEMP_CRON_FILE} | crontab -

rm ${TEMP_CRON_FILE}

sed -E -i -e "s/PHP_VERSION/${PHP_VERSION}/g" /supervisord.conf

#if [[ "${ENABLE_DEBUG}" != "TRUE" ]]; then
#  rm -rf /etc/php/"${PHP_VERSION}"/fpm/conf.d/10-xdebug.ini
#  rm -rf /etc/php/"${PHP_VERSION}"/cli/conf.d/10-xdebug.ini
#fi

if [[ "${ENABLE_DEBUG}" = "TRUE" ]]; then
  ln -sf /etc/php/"${PHP_VERSION}"/mods-available/10-xdebug.ini /etc/php/"${PHP_VERSION}"/fpm/conf.d/10-xdebug.ini && \
  ln -sf /etc/php/"${PHP_VERSION}"/mods-available/10-xdebug.ini /etc/php/"${PHP_VERSION}"/cli/conf.d/10-xdebug.ini
fi

if [[ "${GEN_LV_ENV}" = "TRUE" ]]; then
  env | grep 'LVENV_' | sort | sed -E -e 's/"/\\"/g' -e 's#LVENV_(.*)=#\1=#' -e 's#=(.+)#="\1"#' > /site/web/.env
fi

# Try to fix rsyslogd: file '/dev/stdout': open error: Permission denied
chmod -R a+w /dev/stdout
chmod -R a+w /dev/stderr
chmod -R a+w /dev/stdin

find /site -not -user web -execdir chown "web:" {} \+

if [[ -e "${INITIALISE_FILE}" ]]; then
  chown web: "${INITIALISE_FILE}"
  chmod u+x "${INITIALISE_FILE}"
  chmod a+r /root/.composer
  su web --preserve-environment -c "${INITIALISE_FILE}" >> /site/logs/initialise.log
fi

sed -Ei \
  -e "s/NGINX_SITES/${NGINX_SITES}/" \
  /site/nginx/config/sites.conf

sed -Ei \
  -e "s/LARAVEL_ECHO_PORT/${LARAVEL_ECHO_PORT}/" \
  /site/nginx/config/sites.conf

## Rotate logs at start just in case
/usr/sbin/logrotate -vf /etc/logrotate.d/*.auto &

if [[ "${ELK_METRICBEAT_ACTIVE}" = "TRUE" ]]; then
  sed -E -i -e 's/ELK_METRICBEAT_ACTIVE/true/' /supervisord.conf
else
  sed -E -i -e 's/ELK_METRICBEAT_ACTIVE/false/' /supervisord.conf
fi

if [[ "${ELK_FILEBEAT_ACTIVE}" = "TRUE" ]]; then
  sed -E -i -e 's/ELK_FILEBEAT_ACTIVE/true/' /supervisord.conf
else
  sed -E -i -e 's/ELK_FILEBEAT_ACTIVE/false/' /supervisord.conf
fi

/usr/bin/supervisord -n -c /supervisord.conf
