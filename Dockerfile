# syntax=docker/dockerfile:1
ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_TAG=""

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_TAG=""
ARG PHP_VERSION=''
ARG NODE_MAJOR='20'
ARG TARGETARCH
ARG TZ="UTC"
ARG WEB_USER="web"

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="${TZ}" \
    TIMEZONE="${TZ}"

ENV BASE_IMAGE_NAME="${BASE_IMAGE_NAME}" \
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}" \
    TARGETARCH="${TARGETARCH}" \
    PHP_VERSION="${PHP_VERSION}" \
    NODE_MAJOR="${NODE_MAJOR}" \
    WEB_USER="${WEB_USER}"

ENV JOBS="8"

ENV MAKEFLAGS="-j ${JOBS} --load-average=${JOBS}"

RUN  [ -z "$PHP_VERSION" ] && echo "PHP_VERSION is required" && exit 1 || true

RUN echo "BASE_IMAGE_NAME=${BASE_IMAGE_NAME}" && \
    echo "BASE_IMAGE_TAG=${BASE_IMAGE_TAG}" && \
    echo "NODE_MAJOR=${NODE_MAJOR}" && \
    echo "PHP_VERSION=${PHP_VERSION}" && \
    echo ""

RUN echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4 && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -qy \
      software-properties-common && \
    apt-get update && \
    apt-get install -qy locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_ZA.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    locale-gen en_ZA.UTF-8 && \
    apt-get -qy dist-upgrade && \
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

RUN add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y autoremove

RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg > /dev/null && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      postgresql-client \
      && \
    apt-get -y autoremove

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | \
      tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -y nodejs && \
    apt-get -y autoremove

RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      bash-completion build-essential \
      bzip2 \
      curl cron \
      dos2unix dnsutils dumb-init \
      expect \
      ftp fzf \
      gawk git git-extras git-core git-lfs gnupg2 \
      inetutils-ping inetutils-tools \
      jq \
      libssh2-1 libsodium-dev libuuid1 \
      logrotate \
      mysql-client \
      net-tools \
      nginx-extras \
      openssl openssh-server \
      pip procps psmisc \
      postgresql-client \
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
    && \
    update-ca-certificates --fresh && \
    npm install -g svgo && \
    apt-get -y autoremove

# Install node for headless testing
RUN npm install -g yarn@latest npm@latest npm-check-updates@latest

# Install chrome for headless testing
RUN add-apt-repository ppa:saiarcot895/chromium-beta -y && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
          chromium-browser \
          fonts-liberation \
          libasound2 libnspr4 libnss3 libxss1 xdg-utils  \
          libappindicator1 \
          libappindicator3-1 libatk-bridge2.0-0 libatspi2.0-0 libgbm1 libgtk-3-0 \
        && \
    apt-get -y autoremove || \
    true

RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    \
    apt-get -y install \
      libbrotli-dev libbrotli1 \
      libcurl4 libcurl4-openssl-dev \
      libicu[67]* libicu-* \
      libidn1* libidn1*-dev \
      libidn2-0 libidn2-dev \
      libmcrypt4 libmcrypt-dev \
      libzstd1 libzstd-dev \
      php${PHP_VERSION}-cli php${PHP_VERSION}-fpm php${PHP_VERSION}-swoole \
      php${PHP_VERSION}-bcmath php${PHP_VERSION}-bz2 \
      php${PHP_VERSION}-common php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dev php${PHP_VERSION}-decimal \
      php${PHP_VERSION}-gd php${PHP_VERSION}-gmp php${PHP_VERSION}-grpc \
      php${PHP_VERSION}-http \
      php${PHP_VERSION}-igbinary php${PHP_VERSION}-imagick php${PHP_VERSION}-inotify php${PHP_VERSION}-intl \
      php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-pcov php${PHP_VERSION}-pgsql php${PHP_VERSION}-protobuf \
      php${PHP_VERSION}-raphf php${PHP_VERSION}-rdkafka php${PHP_VERSION}-readline php${PHP_VERSION}-redis \
      php${PHP_VERSION}-soap php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-ssh2 php${PHP_VERSION}-swoole \
      php${PHP_VERSION}-xdebug php${PHP_VERSION}-xml \
      php${PHP_VERSION}-uuid \
      php${PHP_VERSION}-zip \
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
    echo "extension=excimer.so" > "/etc/php/${PHP_VERSION}/mods-available/excimer.ini" && \
    phpenmod -v ${PHP_VERSION} excimer || \
    true

#RUN test "${PHP_VERSION}" != "8.2" &&  \
#    apt-get update && \
#    apt-get -qy dist-upgrade && \
#    \
#    apt-get -y install \
#      php${PHP_VERSION}-mcrypt \
#     && \
#    apt-get -y autoremove || true

COPY --link ./files/php/10-xdebug.ini "/etc/php/${PHP_VERSION}/mods-available/10-xdebug.ini"

ENV PHP_TIMEZONE="UTC" \
    PHP_UPLOAD_MAX_FILESIZE="128M" \
    PHP_POST_MAX_SIZE="128M" \
    PHP_MEMORY_LIMIT="3G" \
    PHP_MAX_EXECUTION_TIME="600" \
    PHP_MAX_INPUT_TIME="600" \
    PHP_DEFAULT_SOCKET_TIMEOUT="600" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="128" \
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER="16" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="16229" \
    PHP_OPCACHE_REVALIDATE_PATH="1" \
    PHP_OPCACHE_ENABLE_FILE_OVERRIDE="0" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_REVALIDATE_FREQ="1" \
    PHP_OPCACHE_PRELOAD_FILE="" \
    COMPOSER_PROCESS_TIMEOUT=2000 \
    FPM_LISTEN_BACKLOG=1024 \
    FPM_MAX_CHILDREN=32 \
    FPM_START_SERVERS=4 \
    FPM_MIN_SPARE_SERVERS=4 \
    FPM_MAX_SPARE_SERVERS=8 \
    FPM_MAX_REQUESTS=1000

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    mkdir -p /usr/local/bin && \
    ln -sf /bin/composer /usr/local/bin/composer

RUN   cp /etc/php/${PHP_VERSION}/cli/php.ini /etc/php/${PHP_VERSION}/cli/php.ini.bak && \
      cp /etc/php/${PHP_VERSION}/fpm/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini.bak && \
      sed -Ei \
        -e "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE}/"  \
        -e "s/short_open_tag = .*/short_open_tag = Off/" \
        -e "s@;date.timezone =.*@date.timezone = ${PHP_TIMEZONE}@" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT}/" \
        -e "s/max_execution_time = .*/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" \
        -e "s/max_input_time = .*/max_input_time = ${PHP_MAX_INPUT_TIME}/" \
        -e "s/default_socket_timeout = .*/default_socket_timeout = ${PHP_DEFAULT_SOCKET_TIMEOUT}/" \
        -e "s/;default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
   sed -Ei \
       -e "s/;realpath_cache_size = .*/realpath_cache_size = 16384K/" \
        -e "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" \
        -e "s/;intl.default_locale =/intl.default_locale = en/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/precision.*/precision = 17/" \
        -e "s/;opcache.enable=.*/opcache.enable=1/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/^error_log.+/error_log = stderr/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" \
        -e "s/;opcache.memory_consumption=.*/opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}/" \
        -e "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=${PHP_OPCACHE_INTERNED_STRINGS_BUFFER}/" \
        -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/;opcache.revalidate_path=.*/opcache.revalidate_path=${PHP_OPCACHE_REVALIDATE_PATH}/" \
        -e "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
        -e "s/;opcache.enable_file_override=.*/opcache.enable_file_override=${PHP_OPCACHE_ENABLE_FILE_OVERRIDE}/" \
        -e "s/;opcache.validate_timestamps=.*/opcache.validate_timestamps=${PHP_OPCACHE_VALIDATE_TIMESTAMPS}/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=${PHP_OPCACHE_REVALIDATE_FREQ}/" \
        -e "s/;opcache.save_comments=.*/opcache.save_comments=1/" \
        -e "s/;opcache.load_comments=.*/opcache.load_comments=1/" \
        -e "s/;opcache.dups_fix=.*/opcache.dups_fix=1/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/serialize_precision.*/serialize_precision = -1/" \
        -e "s/precision.*/precision = 16/" \
        /etc/php/${PHP_VERSION}/cli/php.ini \
        /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -Ei \
        -e "s/expose_php.*/expose_php = Off/" \
        -e "s/display_startup_error.*/display_startup_error = Off/" \
        /etc/php/${PHP_VERSION}/fpm/php.ini

RUN sed -Ei \
        -e "s/error_log = .*/error_log = syslog/" \
        -e "s/.*syslog\.ident = .*/syslog.ident = php-fpm/" \
        -e "s/.*log_buffering = .*/log_buffering = yes/" \
        /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    echo "request_terminate_timeout = 600" >> /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

RUN sed -Ei \
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
        -e "s/.*pm\.status_path = .*/pm.status_path = \/fpm-status/" \
        -e "s/.*ping\.path = .*/ping.path = \/fpm-ping/" \
        -e 's/\/run\/php\/.*fpm.sock/\/run\/php\/fpm.sock/' \
        /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

RUN adduser --home /site --uid 1000 --gecos "" --disabled-password --shell /bin/bash "${WEB_USER}" && \
    usermod -a -G tty "${WEB_USER}" && \
    mkdir -p /site/web && \
    mkdir -p /site/logs/php && \
    find /site -not -user web -execdir chown "${WEB_USER}:" {} \+

COPY --link ./files/shell/starship/ "/root/.config/"
COPY --link ./files/shell/zshrc/ "/root/"

COPY --link --chown="${WEB_USER}:" --chmod=0500 ./files/shell/starship/ "/site/.config/"
COPY --link --chown="${WEB_USER}:" --chmod=0500 ./files/shell/zshrc/ "/site/"

RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

RUN cd /root/ && \
    git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab /root/.oh-my-zsh/custom/plugins/fzf-tab && \
    cp -rf /root/.oh-my-zsh /root/.zshrc /site/ && \
    echo 'eval "$(starship init bash)"' >> /root/.bashrc && \
    echo 'eval "$(starship init bash)"' >> /site/.bashrc && \
    find /site -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+ && \
    find /site/.oh-my-zsh -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+ && \
    find /site/.bashrc -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+ && \
    find /site/.zshrc -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

COPY --link ./files/artisan-bash-prompt /etc/bash_completion.d/artisan-bash-prompt
COPY --link ./files/composer-bash-prompt /etc/bash_completion.d/composer-bash-prompt

RUN echo 'PATH="/usr/bin:/site/web/pharbin:/site/web/vendor/bin:/site/web/vendor/bin:/site/.composer/vendor/bin:${PATH}"' >> /site/.bashrc && \
    echo 'shopt -s histappend' >> /site/.bashrc && \
    echo 'PROMPT_COMMAND="history -a;$PROMPT_COMMAND"' >> /site/.bashrc && \
    echo 'cd /site/web' >> /site/.bashrc && \
    mkdir -p /site/web/pharbin && \
    touch /root/.bash_profile /site/.bash_profile && \
    chown root: /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod u+rw /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod go+r /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    mkdir -p /run/php

WORKDIR /site/web

RUN mkdir -p /site/tmp && \
    find /site -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+ && \
    find /site/.bash_profile -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+ && \
    find /site/tmp -not -user "${WEB_USER}" -execdir chown "${WEB_USER}:" {} \+

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

## add pgcsv for csv to posgres import
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade --default-timeout=100 pgcsv

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
    ENABLE_SIMPLE_QUEUE="FALSE" \
    SIMPLE_WORKER_NUM="5" \
    ENABLE_SSH="FALSE"

COPY --link ./files/supervisord_base.conf /supervisord_base.conf

COPY --link ./files/rsyslog.conf /etc/rsyslog.conf
COPY --link ./files/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf

COPY --link --chmod=0744 ./files/run_with_env.sh /bin/run_with_env.sh
COPY --link --chmod=0744 ./files/start.sh /start.sh
COPY --link --chmod=0744 ./files/testLoop.sh /testLoop.sh
COPY --link --chmod=0744 ./files/healthCheck.sh /healthCheck.sh

HEALTHCHECK \
  --interval=30s \
  --timeout=30s \
  --start-period=15s \
  --retries=10 \
  CMD /healthCheck.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]


CMD ["/start.sh"]
