#!/usr/bin/env bash
set -e

# This script centralizes configuration modifications for PHP and Nginx.
# It expects all necessary environment variables (PHP_VERSION, PHP_UPLOAD_MAX_FILESIZE, etc.)
# to be set before it is executed.

echo "--- Applying PHP INI configurations ---"
sed -Ei \
  -e "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
  -e "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/"  \
  -e "s/short_open_tag = .*/short_open_tag = Off/" \
  -e "s@;?date.timezone =.*@date.timezone = ${PHP_TIMEZONE}@" \
  -e "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" \
  -e "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" \
  -e "s/max_input_time = .*/max_input_time = ${PHP_MAX_INPUT_TIME}/" \
  -e "s/default_socket_timeout = .*/default_socket_timeout = ${PHP_DEFAULT_SOCKET_TIMEOUT}/" \
  -e "s/;?default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
  -e "s/;?realpath_cache_size = .*/realpath_cache_size = ${PHP_REALPATH_CACHE_SIZE}/" \
  -e "s/;?realpath_cache_ttl = .*/realpath_cache_ttl = ${PHP_REALPATH_CACHE_TTL}/" \
  -e "s/;?intl.default_locale =/intl.default_locale = en/" \
  -e "s/serialize_precision.*/serialize_precision = ${PHP_SERIAL_PRECISION}/" \
  -e "s/precision.*/precision = ${PHP_PRECISION}/" \
  -e "s#^;?error_log = .*#error_log = ${PHP_ERROR_LOG}#" \
  -e "s#^;?syslog.ident = .*#syslog.ident = ${PHP_IDENT}#" \
  -e "s/;?opcache.enable_cli=.*/opcache.enable_cli=1/" \
  -e "s/;?opcache.enable=.*/opcache.enable=1/" \
  -e "s/;?opcache.memory_consumption=.*/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/" \
  -e "s/;?opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER}/" \
  -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}/" \
  -e "s/;?opcache.revalidate_path=.*/opcache.revalidate_path=${PHP_OPCACHE_REVALIDATE_PATH}/" \
  -e "s/;?opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
  -e "s/;?opcache.enable_file_override=.*/opcache.enable_file_override=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE}/" \
  -e "s/;?opcache.validate_timestamps=.*/opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}/" \
  -e "s/;?opcache.save_comments=.*/opcache.save_comments=1/" \
  -e "s/;?opcache.load_comments=.*/opcache.load_comments=1/" \
  -e "s/;?opcache.revalidate_freq=.*/opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ}/" \
  -e "s/;?opcache.dups_fix=.*/opcache.dups_fix=1/" \
  -e "s/;?opcache.max_wasted_percentage=.*/;opcache.max_wasted_percentage=10/" \
  -e "s/precision = .*/precision = -1/" \
  -e "s/expose_php.*/expose_php = Off/" \
  -e "s/display_startup_error.*/display_startup_error = Off/" \
  "/etc/php/${PHP_VERSION}/cli/php.ini" \
  "/etc/php/${PHP_VERSION}/fpm/php.ini"

echo "--- Applying PHP-FPM main configurations ---"
sed -Ei \
  -e "s#error_log = .*#error_log = ${PHP_ERROR_LOG}#" \
  -e "s#.*syslog\.ident = .*#syslog.ident = ${PHP_FPM_IDENT}#" \
  -e "s/.*log_buffering = .*/log_buffering = yes/" \
  "/etc/php/${PHP_VERSION}/fpm/php-fpm.conf"

echo "--- Applying PHP-FPM www pool configurations ---"
sed -Ei \
  -e "s#^(;|)access.log = .*#access.log = ${PHP_ACCESS_LOG}#" \
  -e "s/^user = .*/user = ${WEB_USER}/" \
  -e "s/^group = .*/group = ${WEB_USER}/" \
  -e "s/listen\.owner.*/listen.owner = ${WEB_USER}/" \
  -e "s/listen\.group.*/listen.group = ${WEB_USER}/" \
  -e "s/.*listen\.backlog.*/listen.backlog = ${FPM_LISTEN_BACKLOG}/" \
  -e "s/^pm\.max_children = .*/pm.max_children = ${FPM_MAX_CHILDREN}/" \
  -e "s/^pm\.start_servers = .*/pm.start_servers = ${FPM_START_SERVERS}/" \
  -e "s/^pm\.min_spare_servers = .*/pm.min_spare_servers = ${FPM_MIN_SPARE_SERVERS}/" \
  -e "s/^pm\.max_spare_servers = .*/pm.max_spare_servers = ${FPM_MAX_SPARE_SERVERS}/" \
  -e "s/.*pm\.max_requests = .*/pm.max_requests = ${FPM_MAX_REQUESTS}/" \
  -e "s/^(;|)catch_workers_output = .*/catch_workers_output = yes/" \
  -e "s/^(;|)decorate_workers_output = .*/decorate_workers_output = no/" \
  -e "s/.*pm\.status_path = .*/pm.status_path = \/fpm-status/" \
  -e "s/^(;|)pm.status_listen = .*/pm.status_listen = 127.0.0.1:9001/" \
  -e "s/^(;|)ping\.path = .*/ping.path = \/fpm-ping/" \
  -e "s/\/run\/php\/.*fpm.sock/\/run\/php\/fpm.sock/" \
  -e "s/;?request_terminate_timeout = .*/request_terminate_timeout = ${FPM_TIMEOUT}/" \
  -e "s/^(;|)clear_env = .*/clear_env = no/" \
  "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

if [[ "${PHP_OPCACHE_JIT_ENABLED}" = "TRUE" ]]; then
  echo "--- Creating opcache JIT configuration file ---"
  cat > "/etc/php/${PHP_VERSION}/mods-available/opcache-jit.ini" << EOF
; Ability to disable jit if enabling debugging
opcache.jit_buffer_size=${PHP_OPCACHE_JIT_BUFFER_SIZE}
opcache.jit=${PHP_OPCACHE_JIT}
EOF
else
  # Remove opcache JIT config file if it exists
  if [[ -f "/etc/php/${PHP_VERSION}/mods-available/opcache-jit.ini" ]]; then
    echo "--- Removing opcache JIT configuration file ---"
    rm -f "/etc/php/${PHP_VERSION}/mods-available/opcache-jit.ini"
  fi
fi

# Only apply Nginx changes if NGINX_SITES is set (likely runtime)
if [[ -n "${NGINX_SITES}" ]]; then
  echo "--- Applying Nginx site configurations ---"
  sed -Ei \
    -e "s/NGINX_SITES/${NGINX_SITES}/" \
    -e "s/LARAVEL_WEBSOCKETS_PORT/${LARAVEL_WEBSOCKETS_PORT}/" \
    /site/nginx/config/sites.conf

  echo "--- Applying Nginx main configurations (if vars set) ---"
  if [[ -n "${NGINX_CLIENT_BODY_BUFFER_SIZE}" ]]; then
    sed -Ei -e "s/client_body_buffer_size .+/client_body_buffer_size ${NGINX_CLIENT_BODY_BUFFER_SIZE};/" /site/nginx/config/nginx.conf
  fi

  if [[ -n "${NGINX_CLIENT_MAX_BODY_SIZE}" ]]; then
    sed -Ei -e "s/client_max_body_size .+/client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};/" /site/nginx/config/nginx.conf
  fi
fi

echo "--- Configuration script finished ---"
