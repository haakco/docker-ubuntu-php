# syntax=docker/dockerfile:1
ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_VERSION=""

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_VERSION}

LABEL org.opencontainers.image.authors="timh@haak.co"
LABEL org.opencontainers.image.source="https://github.com/haakco/docker-ubuntu-php"
LABEL org.opencontainers.image.title="docker-ubuntu-php-laravel"
LABEL org.opencontainers.image.description="Base image for laravel projects"
LABEL org.opencontainers.image.vendor="HaakCo"

ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_VERSION=""
ARG PHP_VERSION=''
ARG NODE_MAJOR='20'
ARG TARGETARCH
ARG TARGETOS
ARG TZ="UTC"
ARG WEB_USER="web"
ARG DOCKERIZE_VERSION="v0.7.0"
ARG PHP_IDENT="php"
ARG PHP_FPM_IDENT="php-fpm"
ARG PHP_ERROR_LOG="/proc/self/fd/2"
ARG PHP_ACCESS_LOG="/proc/self/fd/2"

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_ZA.UTF-8" \
    LANGUAGE="en_ZA.UTF-8" \
    LC_ALL="en_ZA.UTF-8" \
    LC_MEASUREMENT="en_ZA.UTF-8" \
    TERM="xterm-256color" \
    TZ="${TZ}" \
    TIMEZONE="${TZ}"

ENV BASE_IMAGE_NAME="${BASE_IMAGE_NAME}" \
    BASE_IMAGE_VERSION="${BASE_IMAGE_VERSION}" \
    TARGETARCH="${TARGETARCH}" \
    TARGETOS="${TARGETOS}" \
    NODE_MAJOR="${NODE_MAJOR}" \
    DOCKERIZE_VERSION=${DOCKERIZE_VERSION}

ENV PHP_VERSION="${PHP_VERSION}" \
    WEB_HOME_DIR="/site/web" \
    WEB_USER="${WEB_USER}" \
    WEB_USER_ID="1000" \
    WEB_GROUP_ID="1000" \
    WEB_USER_HOME="/site" \
    WEB_USER_SHELL="/bin/bash"


ENV JOBS="16"

ENV MAKEFLAGS="-j ${JOBS} --load-average=${JOBS}"

RUN  [ -z "$PHP_VERSION" ] && echo "PHP_VERSION is required" && exit 1 || true

RUN echo "BASE_IMAGE_NAME=${BASE_IMAGE_NAME}" && \
    echo "BASE_IMAGE_VERSION=${BASE_IMAGE_VERSION}" && \
    echo "NODE_MAJOR=${NODE_MAJOR}" && \
    echo "PHP_VERSION=${PHP_VERSION}" && \
    echo ""

RUN apt-get update && \
    apt-get -qy dist-upgrade

RUN apt-get install -qy \
      software-properties-common \
      locales \
    && \
    apt-get -qy dist-upgrade && \
    echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_ZA.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get install -qy \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      software-properties-common sudo \
      tzdata \
      && \
    apt-get -y autoremove

RUN apt-get install -qy \
      bat bash-completion build-essential bzip2 \
      curl cron \
      dos2unix dnsutils dumb-init \
      expect \
      ftp fzf \
      gawk git git-extras git-core git-lfs golang gnupg2 \
      ghostscript ghostscript-x gsfonts-other \
      imagemagick imagemagick-common inetutils-ping inetutils-tools \
      jq \
      libssh2-1 libsodium-dev libuuid1 \
      logrotate \
      mysql-client \
      net-tools nginx-extras \
      openssl openssh-server \
      pip procps psmisc \
      redis-tools \
      rsync \
      rsyslog rsyslog-kubernetes  \
      rsyslog-openssl rsyslog-relp rsyslog-snmp rsyslog-gnutls \
      supervisor \
      tar telnet thefuck tmux tmuxinator traceroute tree \
      unzip \
      uuid-dev \
      vim \
      wget whois \
      xz-utils \
      yamllint \
      zlib1g-dev \
      zsh zsh-syntax-highlighting zsh-autosuggestions zsh-common \
    \
    ffmpeg \
    libavcodec-extra libavformat-extra libavfilter-extra \
    \
    gifsicle \
    jpegoptim \
    libavif-bin \
    optipng \
    pngquant \
    gifsicle \
    webp \
    \
    && \
    update-ca-certificates --fresh && \
    apt-get -y autoremove

RUN GOBIN=/usr/local/bin/ go install github.com/google/yamlfmt/cmd/yamlfmt@latest

RUN echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg > /dev/null && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
      postgresql-client \
    && \
    apt-get -y autoremove

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | \
      tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
      nodejs \
    && \
    apt-get -y autoremove && \
    npm install -g svgo yarn@latest npm@latest npm-check-updates@latest

#RUN npx @puppeteer/browsers install --path /site/chrome chrome@stable && \
#    npx @puppeteer/browsers install --path /site/chrome chromedriver

#RUN gpg --keyserver keyserver.ubuntu.com --recv-key 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
#    gpg --output /etc/apt/trusted.gpg.d/ondrej-php-new2.gpg --export 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
#    deb [signed-by=/etc/apt/trusted.gpg.d/ondrej-php.gpg] https://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ondrej-php.list && \
#    apt-get update

COPY --link ./files/php /root/php

RUN cat /root/php/ondrej-php.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/ondrej-php.gpg >/dev/null && \
    cat /root/php/ondrej-php-old.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/ondrej-php-old.gpg >/dev/null && \
    echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ondrej-php.list && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
      libbrotli-dev libbrotli1 \
      libcurl4 libcurl4-openssl-dev \
      libicu[67]* libicu-* \
      libidn1* libidn1*-dev \
      libidn2-0 libidn2-dev \
      libmcrypt4 libmcrypt-dev \
      libzstd1 libzstd-dev \
      php${PHP_VERSION}-cli php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-bcmath php${PHP_VERSION}-bz2 \
      php${PHP_VERSION}-common php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-gd php${PHP_VERSION}-gmp \
      php${PHP_VERSION}-http \
      php${PHP_VERSION}-igbinary php${PHP_VERSION}-imagick php${PHP_VERSION}-inotify php${PHP_VERSION}-intl \
      php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-pcov php${PHP_VERSION}-pgsql \
      php${PHP_VERSION}-opentelemetry \
      php${PHP_VERSION}-raphf php${PHP_VERSION}-readline php${PHP_VERSION}-redis php${PHP_VERSION}-rdkafka \
      php${PHP_VERSION}-soap php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-ssh2 \
      php${PHP_VERSION}-xdebug php${PHP_VERSION}-xml php${PHP_VERSION}-xsl \
      php${PHP_VERSION}-zip php${PHP_VERSION}-zstd \
    && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    apt-get install -y \
      php-pear \
      pear-channels \
      && \
    apt-get -y autoremove && \
    echo "web        soft        nofile        100000" > /etc/security/limits.d/laravel-echo.conf && \
    pecl install brotli && \
    echo "extension=brotli.so" > "/etc/php/${PHP_VERSION}/mods-available/brotli.ini" && \
    pecl install excimer && \
    echo "extension=excimer.so" > "/etc/php/${PHP_VERSION}/mods-available/excimer.ini"

RUN phpenmod -v "${PHP_VERSION}" excimer || \
    phpdismod -v "${PHP_VERSION}" xdebug  || \
    phpdismod -v "${PHP_VERSION}" pcov

#RUN test "${PHP_VERSION}" != "8.2" &&  \
#    apt-get update && \
#    apt-get -qy dist-upgrade && \
#    \
#    apt-get -y install \
#      php${PHP_VERSION}-mcrypt \
#     && \
#    apt-get -y autoremove || true


ENV PHP_TIMEZONE="UTC" \
    PHP_UPLOAD_MAX_FILESIZE="256M" \
    PHP_POST_MAX_SIZE="256M" \
    PHP_MEMORY_LIMIT="3G" \
    PHP_MAX_EXECUTION_TIME="600" \
    PHP_MAX_INPUT_TIME="600" \
    PHP_SERIAL_PRECISION="-1" \
    PHP_PRECISION="-1" \
    PHP_DEFAULT_SOCKET_TIMEOUT="600" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="512" \
    PHP_OPCACHE_JIT_BUFFER_SIZE="256M" \
    PHP_OPCACHE_JIT="1205" \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER="64" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="65536" \
    PHP_OPCACHE_REVALIDATE_PATH="1" \
    PHP_OPCACHE_ENABLE_FILE_OVERRIDE="0" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_REVALIDATE_FREQ="1" \
    COMPOSER_PROCESS_TIMEOUT=2000 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    \
    FPM_TIMEOUT=600 \
    FPM_LISTEN_BACKLOG=1024 \
    FPM_MAX_CHILDREN=32 \
    FPM_START_SERVERS=4 \
    FPM_MIN_SPARE_SERVERS=4 \
    FPM_MAX_SPARE_SERVERS=8 \
    FPM_MAX_REQUESTS=1000 \
    \
    PHP_IDENT="${PHP_IDENT}" \
    PHP_FPM_IDENT="${PHP_FPM_IDENT}" \
    PHP_ERROR_LOG="${PHP_ERROR_LOG}" \
    PHP_ACCESS_LOG="${PHP_ACCESS_LOG}" \
    \
    PHP_INI_CLI_CONFIG_FILE="/etc/php/${PHP_VERSION}/cli/php.ini" \
    PHP_INI_FPM_CONFIG_FILE="/etc/php/${PHP_VERSION}/fpm/php.ini" \
    PHP_FPM_CONFIG_FILE="/etc/php/${PHP_VERSION}/fpm/php-fpm.conf" \
    PHP_FPM_WWW_CONFIG_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    mkdir -p /usr/local/bin && \
    ln -sf /bin/composer /usr/local/bin/composer

RUN cp "${PHP_INI_CLI_CONFIG_FILE}" "${PHP_INI_CLI_CONFIG_FILE}".bak && \
    cp "${PHP_INI_FPM_CONFIG_FILE}" "${PHP_INI_FPM_CONFIG_FILE}".bak

RUN sed -Ei \
      -e "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
      -e "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/"  \
      -e "s/short_open_tag = .*/short_open_tag = Off/" \
      -e "s@;date.timezone =.*@date.timezone = ${PHP_TIMEZONE}@" \
      -e "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" \
      -e "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" \
      -e "s/max_input_time = .*/max_input_time = ${PHP_MAX_INPUT_TIME}/" \
      -e "s/default_socket_timeout = .*/default_socket_timeout = ${PHP_DEFAULT_SOCKET_TIMEOUT}/" \
      -e "s/;default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
      -e "s/;realpath_cache_size = .*/realpath_cache_size = 16384K/" \
      -e "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" \
      -e "s/;intl.default_locale =/intl.default_locale = en/" \
      -e "s/serialize_precision.*/serialize_precision = ${PHP_SERIAL_PRECISION}/" \
      -e "s/precision.*/precision = ${PHP_PRECISION}/" \
      -e "s#^(;|)error_log = .*#error_log = ${PHP_ERROR_LOG}#" \
      -e "s#^(;|)syslog.ident = .*#syslog.ident = ${PHP_IDENT}#" \
    \
      -e "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" \
      -e "s/;opcache.enable=.*/opcache.enable=1/" \
      -e "s/;opcache.memory_consumption=.*/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/" \
      -e "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER}/" \
      -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}/" \
      -e "s/;opcache.revalidate_path=.*/opcache.revalidate_path=${PHP_OPCACHE_REVALIDATE_PATH}/" \
      -e "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
      -e "s/;opcache.enable_file_override=.*/opcache.enable_file_override=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE}/" \
      -e "s/;opcache.validate_timestamps=.*/opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}/" \
      -e "s/;opcache.save_comments=.*/opcache.save_comments=1/" \
      -e "s/;opcache.load_comments=.*/opcache.load_comments=1/" \
      -e "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ}/" \
      -e "s/;opcache.dups_fix=.*/opcache.dups_fix=1/" \
      -e "s/;opcache.max_wasted_percentage=.*/;opcache.max_wasted_percentage=10/" \
      "${PHP_INI_CLI_CONFIG_FILE}" \
      "${PHP_INI_FPM_CONFIG_FILE}"

RUN <<FILE1 cat > /etc/php/${PHP_VERSION}/mods-available/opcache-jit.ini
; Ability to disable jit if enabling debugging
opcache.jit_buffer_size=${PHP_OPCACHE_JIT_BUFFER_SIZE}
opcache.jit=${PHP_OPCACHE_JIT}
FILE1

RUN sed -Ei \
        -e "s/precision = .*/precision = -1/" \
        -e "s/expose_php.*/expose_php = Off/" \
        -e "s/display_startup_error.*/display_startup_error = Off/" \
      "${PHP_INI_CLI_CONFIG_FILE}" \
      "${PHP_INI_FPM_CONFIG_FILE}"

RUN sed -Ei \
        -e "s#error_log = .*#error_log = ${PHP_ERROR_LOG}#" \
        -e "s#.*syslog\.ident = .*#syslog.ident = ${PHP_FPM_IDENT}#" \
        -e "s/.*log_buffering = .*/log_buffering = yes/" \
        /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

RUN sed -Ei \
        -e "s#^(;|)access.log = .*#access.log = ${PHP_ACCESS_LOG}#" \
        -e "s/^user = .*/user = ${WEB_USER}/" \
        -e "s/^group = .*/group = ${WEB_USER}/" \
        -e 's/listen\.owner.*/listen.owner = ${WEB_USER}/' \
        -e 's/listen\.group.*/listen.group = ${WEB_USER}/' \
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
        -e 's/\/run\/php\/.*fpm.sock/\/run\/php\/fpm.sock/' \
        -e 's/;request_terminate_timeout = .*/request_terminate_timeout = ${FPM_TIMEOUT}/' \
        /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

RUN cat <<-EOF >> "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
  php_flag[display_errors] = off
  php_admin_flag[log_errors] = on
  php_admin_flag[fastcgi.logging] = off
  php_admin_value[error_log] = ${PHP_ERROR_LOG}
EOF

RUN wget -O - "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-${TARGETOS}-${TARGETARCH}-${DOCKERIZE_VERSION}.tar.gz" | tar xzf - -C /usr/local/bin


## Why add a user in the first place? :(
RUN deluser --remove-home ubuntu || true

RUN adduser --home /site --uid 1000 --gecos "" --disabled-password --shell /bin/bash "${WEB_USER}" && \
    usermod -a -G tty "${WEB_USER}" && \
    mkdir -p /site/web && \
    mkdir -p /site/logs/php && \
    find /site -not -user web -execdir chown "${WEB_USER}:" {} \+

COPY --link ./files/shell/starship/ "/root/.config/"
COPY --link ./files/shell/zshrc/ "/root/"
COPY --link ./files/shell/bash/ "/root/"

COPY --link --chown="${WEB_USER}:" --chmod=0500 ./files/shell/starship/ "/site/.config/"
COPY --link --chown="${WEB_USER}:" --chmod=0500 ./files/shell/zshrc/ "/site/"

RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    cargo install eza

RUN cd /root/ && \
    git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab /root/.oh-my-zsh/custom/plugins/fzf-tab && \
    sudo curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh -o /usr/share/doc/fzf/examples/completion.zsh && \
    sudo curl https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -o /usr/share/doc/fzf/examples/key-bindings.zsh && \
    git clone --depth 1 https://github.com/chrissicool/zsh-256color "/root/.oh-my-zsh/custom/plugins/zsh-256color" && \
    git clone https://github.com/jessarcher/zsh-artisan.git ~/.oh-my-zsh/custom/plugins/artisan && \
    cp -rf /root/.oh-my-zsh /root/.zshrc /site/ && \
    cat /root/bash_extra >> /root/.bashrc && \
    cat /root/bash_extra >> /site/.bashrc && \
    chsh -s $(which zsh) root && \
    chsh -s $(which zsh) "${WEB_USER}" && \
    find /site -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

COPY --link ./files/artisan-bash-prompt /etc/bash_completion.d/artisan-bash-prompt
COPY --link ./files/composer-bash-prompt /etc/bash_completion.d/composer-bash-prompt

RUN mkdir -p /site/web/pharbin && \
    touch /root/.bash_profile /site/.bash_profile && \
    chown root: /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod u+rw /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod go+r /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    mkdir -p /run/php

WORKDIR /site/web

RUN mkdir -p /site/tmp && \
    find /site -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

COPY --link ./files/nginx_config /site/nginx/config

RUN mkdir -p /site/logs/nginx && \
    mkdir -p /var/lib/nginx && \
    find /var/lib/nginx -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=600 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

USER "${WEB_USER}"

##    Does not support php 8.0 yet
#    composer global require sllh/composer-versions-check && \
#    composer global require povils/phpmnd

#    Not needed for new composer
#    composer global require hirak/prestissimo && \

RUN composer config --global process-timeout "${COMPOSER_PROCESS_TIMEOUT}"

USER root

COPY --link ./files/logrotate.d/ /etc/logrotate.d/

RUN find /site -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

RUN chmod -R a+w /dev/stdout && \
    chmod -R a+w /dev/stderr && \
    chmod -R a+w /dev/stdin && \
    usermod -a -G tty syslog && \
    usermod -a -G tty "${WEB_USER}"

# Add openssh
RUN ssh-keygen -A && \
    mkdir -p /run/sshd && \
    mkdir -p /run/sshd

RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    chown -R root:root /root/.ssh

COPY --chown=root: ./files/ssh/config /root/.ssh/config

RUN mkdir -p /site/.ssh && \
    chmod 700 /site/.ssh && \
    touch /site/.ssh/authorized_keys && \
    chmod 600 /site/.ssh/authorized_keys && \
    chown -R "${WEB_USER}:" /site/.ssh

COPY --chown="${WEB_USER}:" ./files/ssh/config /site/.ssh/config

ENV NGINX_SITES='locahost' \
    ENABLE_DEBUG="FALSE" \
    GEN_LV_ENV="FALSE" \
    INITIALISE_FILE="/site/web/initialise.sh" \
    LV_DO_CACHING="FALSE" \
    ENABLE_HORIZON="FALSE" \
    ENABLE_PULSE_CHECK="FALSE" \
    ENABLE_PULSE_WORK="FALSE" \
    ENABLE_SIMPLE_QUEUE="FALSE" \
    SIMPLE_WORKER_NUM="5" \
    ENABLE_SSH="FALSE" \
    ENABLE_HEALTH_CHECK="FALSE"

COPY --link ./files/supervisord_base.conf /supervisord_base.conf

COPY --link ./files/rsyslog.conf /etc/rsyslog.conf
COPY --link ./files/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf

COPY --link --chmod=0755 ./files/run_with_env.sh /bin/run_with_env.sh
COPY --link --chmod=0744 ./files/start.sh /start.sh
COPY --link --chmod=0744 ./files/testLoop.sh /testLoop.sh
COPY --link --chmod=0744 ./files/healthCheck.sh /healthCheck.sh

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --start-period=15s \
  --retries=60 \
  CMD /healthCheck.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]


CMD ["/start.sh"]
