# syntax=docker/dockerfile:1.3
ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_TAG=""

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_TAG=""
ARG PHP_VERSION=''

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="UTC"

ENV BASE_IMAGE_NAME="${BASE_IMAGE_NAME}" \
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}" \
    PHP_VERSION="${PHP_VERSION}"

ENV JOBS="8"

ENV MAKEFLAGS="-j ${JOBS} --load-average=${JOBS}"

RUN  [ -z "$PHP_VERSION" ] && echo "PHP_VERSION is required" && exit 1 || true

RUN echo "BASE_IMAGE_NAME=${BASE_IMAGE_NAME}" && \
    echo "BASE_IMAGE_TAG=${BASE_IMAGE_TAG}" && \
    echo "PHP_VERSION=${PHP_VERSION}" && \
    echo ""

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
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
      software-properties-common \
      tzdata \
      && \
    apt-get -y autoremove

RUN add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y autoremove

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/postgresql.gpg  > /dev/null && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      postgresql-client \
      && \
    apt-get -y autoremove

RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      bash-completion build-essential \
      bzip2 \
      ca-certificates cron curl \
      dos2unix dnsutils \
      expect \
      ftp fzf \
      gawk git git-core gnupg \
      inetutils-ping inetutils-tools \
      jq \
      logrotate \
      libssh2-1 libsodium-dev libuuid1 \
      mysql-client \
      net-tools \
      postgresql-client \
      openssl \
      pip procps psmisc \
      rsync rsyslog \
      redis-tools \
      sudo supervisor \
      tar telnet tmux traceroute tree \
      unzip \
      wget whois \
      vim \
      uuid-dev \
      xz-utils \
      zlib1g-dev && \
    update-ca-certificates --fresh && \
    apt-get -y autoremove


RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
      php7.4-propro && \
    apt-get -y autoremove


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
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-common php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-gd php${PHP_VERSION}-gmp \
      php${PHP_VERSION}-http \
      php${PHP_VERSION}-igbinary php${PHP_VERSION}-imagick php${PHP_VERSION}-intl \
      php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-mcrypt \
      php${PHP_VERSION}-pcov php${PHP_VERSION}-pgsql php${PHP_VERSION}-protobuf \
      php${PHP_VERSION}-raphf php${PHP_VERSION}-redis \
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
    echo "extension=redis.so" > "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" && \
    echo "extension=mcrypt.so" > "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" || \
     true

#RUN test "${PHP_VERSION}" != "8.2" &&  \
#    apt-get update && \
#    apt-get -qy dist-upgrade && \
#    \
#    apt-get -y install \
#      php${PHP_VERSION}-mcrypt \
#     && \
#    apt-get -y autoremove || true

ADD ./files/php/10-xdebug.ini "/etc/php/${PHP_VERSION}/mods-available/10-xdebug.ini"

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
    COMPOSER_PROCESS_TIMEOUT=2000

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
        -e "s/^user = .*/user = web/" \
        -e "s/^group = .*/group = web/" \
        -e 's/listen\.owner.*/listen.owner = web/' \
        -e 's/listen\.group.*/listen.group = web/' \
        -e 's/.*listen\.backlog.*/listen.backlog = 65536/' \
        -e "s/pm\.max_children = .*/pm.max_children = 32/" \
        -e "s/pm\.start_servers = .*/pm.start_servers = 4/" \
        -e "s/pm\.min_spare_servers = .*/pm.min_spare_servers = 4/" \
        -e "s/pm\.max_spare_servers = .*/pm.max_spare_servers = 16/" \
        -e "s/.*pm\.max_requests = .*/pm.max_requests = 0/" \
        -e "s/.*pm\.status_path = .*/pm.status_path = \/fpm-status/" \
        -e "s/.*ping\.path = .*/ping.path = \/fpm-ping/" \
        -e 's/\/run\/php\/.*fpm.sock/\/run\/php\/fpm.sock/' \
        /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

#    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
RUN add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy git-lfs && \
    git lfs install && \
    apt-get -y autoremove

ADD ./files/zshrc/zshrc.in /root/.zshrc

#    echo "web:`date +%s | sha256sum | base64 | head -c 32`" | chpasswd && \
RUN adduser --home /site --uid 1000 --gecos "" --disabled-password --shell /bin/bash web && \
    usermod -a -G tty web && \
    mkdir -p /site/web && \
    mkdir -p /site/logs/php && \
    find /site -not -user web -execdir chown "web:" {} \+


RUN cd /root/ && \
    git clone --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    cp -rf /root/.oh-my-zsh /root/.zshrc /site/ && \
    find /site/.oh-my-zsh -not -user web -execdir chown "web:" {} \+ && \
    find /site/.zshrc -not -user web -execdir chown "web:" {} \+

## Files to add github key for composer
#ADD ./files/composer/auth.json /root/.composer/auth.json
#ADD ./files/composer/auth.json /site/.composer/auth.json

ADD ./files/start.sh /start.sh
ADD ./files/supervisord_base.conf /supervisord_base.conf

ADD ./files/rsyslog.conf /etc/rsyslog.conf
ADD ./files/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf
ADD ./files/artisan-bash-prompt /etc/bash_completion.d/artisan-bash-prompt
ADD ./files/composer-bash-prompt /etc/bash_completion.d/composer-bash-prompt
ADD ./files/run_with_env.sh /bin/run_with_env.sh

RUN echo 'PATH="/usr/bin:/site/web/pharbin:/site/web/vendor/bin:/site/web/vendor/bin:/site/.composer/vendor/bin:${PATH}"' >> /site/.bashrc && \
    echo 'shopt -s histappend' >> /site/.bashrc && \
    echo 'PROMPT_COMMAND="history -a;$PROMPT_COMMAND"' >> /site/.bashrc && \
    echo 'cd /site/web' >> /site/.bashrc && \
    mkdir -p /site/web/pharbin && \
    touch /root/.bash_profile /site/.bash_profile && \
    chown root: /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod u+rw /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt && \
    chmod go+r /etc/bash_completion.d/artisan-bash-prompt /etc/bash_completion.d/composer-bash-prompt

RUN chmod u+x /start.sh && \
    chmod a+x /bin/run_with_env.sh && \
    mkdir -p /run/php

#fix problem with cron
#RUN sed -E -i.back -e 's/(.+pam_loginuid.so)/#\1/' /etc/pam.d/cron

WORKDIR /site/web

RUN mkdir -p /site/tmp && \
    find /site -not -user web -execdir chown "web:" {} \+ && \
    find /site/.bash_profile -not -user web -execdir chown "web:" {} \+ && \
    find /site/tmp -not -user web -execdir chown "web:" {} \+

RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
          nginx-extras \
        && \
    apt-get -y autoremove

ADD ./files/nginx_config /site/nginx/config

RUN mkdir -p /site/logs/nginx && \
    mkdir -p /var/lib/nginx && \
    find /var/lib/nginx -not -user web -execdir chown "web:" {} \+

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=600 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

## add pgcsv for csv to posgres import
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade --default-timeout=100 pgcsv

ADD ./files/testLoop.sh /testLoop.sh
RUN chmod u+x /testLoop.sh

USER web

##    Does not support php 8.0 yet
#    composer global require sllh/composer-versions-check && \
#    composer global require povils/phpmnd

#    Not needed for new composer
#    composer global require hirak/prestissimo && \

RUN composer config --global process-timeout "${COMPOSER_PROCESS_TIMEOUT}"

USER root

ADD ./files/logrotate.d/ /etc/logrotate.d/

RUN find /site -not -user web -execdir chown "web:" {} \+

RUN chmod -R a+w /dev/stdout && \
    chmod -R a+w /dev/stderr && \
    chmod -R a+w /dev/stdin && \
    usermod -a -G tty syslog && \
    usermod -a -G tty web

# Install chrome for headless testing

#RUN test "$(dpkg-architecture -q DEB_BUILD_ARCH)" = "amd64" && \
#    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
#    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
#    apt-get update && \
#    apt-get -qy dist-upgrade && \
#    apt-get -y install \
#          google-chrome-stable \
#          fonts-liberation \
#          libasound2 libnspr4 libnss3 libxss1 xdg-utils  \
#          libappindicator1 \
#          libappindicator3-1 libatk-bridge2.0-0 libatspi2.0-0 libgbm1 libgtk-3-0 \
#        && \
#    apt-get -y autoremove || \
#    true

#RUN test "$(dpkg-architecture -q DEB_BUILD_ARCH)" != "amd64" && \
#    add-apt-repository ppa:saiarcot895/chromium-beta -y && \
#    apt-get update && \
#    apt-get -qy dist-upgrade && \
#    apt-get -y install \
#          chromium-browser \
#          fonts-liberation \
#          libasound2 libnspr4 libnss3 libxss1 xdg-utils  \
#          libappindicator1 \
#          libappindicator3-1 libatk-bridge2.0-0 libatspi2.0-0 libgbm1 libgtk-3-0 \
#        && \
#    apt-get -y autoremove || \
#    true

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

# Install node for headless testing

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | -E bash - && \
    apt-get install -y nodejs && \
    apt-get -y autoremove

RUN npm install -g yarn@latest npm@latest npm-check-updates@latest

RUN test "$(dpkg-architecture -q DEB_BUILD_ARCH)" = "amd64" && \
    add-apt-repository -y ppa:savoury1/graphics && \
    add-apt-repository -y ppa:savoury1/multimedia && \
    add-apt-repository -y ppa:savoury1/ffmpeg4 && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
          ffmpeg \
        && \
    apt-get -y autoremove || \
    true

RUN test "$(dpkg-architecture -q DEB_BUILD_ARCH)" != "amd64" && \
    apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get -y install \
          ffmpeg \
        && \
    apt-get -y autoremove || \
    true

RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      gifsicle \
      jpegoptim \
      optipng \
      pngquant \
      gifsicle \
      webp \
      && \
    apt-get -y autoremove

# Add openssh
RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      openssh-server \
      && \
    ssh-keygen -A && \
    mkdir -p /run/sshd && \
    mkdir -p /run/sshd && \
    apt-get -y autoremove

# Add dumb-init
RUN apt-get update && \
    apt-get -qy dist-upgrade && \
    apt-get install -qy \
      dumb-init \
      && \
    apt-get -y autoremove

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
    chown -R web:web /site/.ssh

COPY --chown=web: ./files/ssh/config /site/.ssh/config

ENV NGINX_SITES='locahost' \
    ENABLE_DEBUG="FALSE" \
    GEN_LV_ENV="FALSE" \
    INITIALISE_FILE="/site/web/initialise.sh" \
    LV_DO_CACHING="FALSE" \
    ENABLE_HORIZON="FALSE" \
    ENABLE_SIMPLE_QUEUE="FALSE" \
    SIMPLE_WORKER_NUM="5" \
    ENABLE_SSH="FALSE"

ADD ./files/healthCheck.sh /healthCheck.sh

RUN chown web: /healthCheck.sh && \
    chmod a+x /healthCheck.sh

HEALTHCHECK \
  --interval=30s \
  --timeout=30s \
  --start-period=15s \
  --retries=10 \
  CMD /healthCheck.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--"]


CMD ["/start.sh"]
