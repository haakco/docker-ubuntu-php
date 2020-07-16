FROM ubuntu:20.04

ARG PHP_VERSION
ARG PROXY=''

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="Africa/Johannesburg" \
    OLD_OVERRIDE_DISTRIB_CODENAME="eoan" \
    DISTRIB_CODENAME="focal" \
    PHP_VERSION=$PHP_VERSION
#     \
#    XDEBUG_VERSION="2.9.0"
RUN  [ -z "$PHP_VERSION" ] && echo "MY_ARG is required" && exit 1 || true

RUN echo "PHP_VERSION=${PHP_VERSION}" && \
    echo "PROXY=${PROXY}" && \
    echo ""

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" install -qy locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_ZA.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    locale-gen en_ZA.UTF-8 && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt -o Acquire::http::proxy="$PROXY" install -qy \
      apt-transport-https \
      software-properties-common \
      tzdata \
      && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

RUN add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ ${OLD_OVERRIDE_DISTRIB_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7FCC7D46ACCC4CF8 && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

RUN echo "deb http://ppa.launchpad.net/maxmind/ppa/ubuntu ${OLD_OVERRIDE_DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/maxmind.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DE1997DCDE742AFA && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

RUN apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -o Acquire::http::proxy="$PROXY" install -qy \
      autojump apt-transport-https \
      bat bash-completion build-essential \
      bzip2 \
      ca-certificates cron curl \
      dos2unix dnsutils \
      expect \
      ftp fzf \
      gawk git git-core \
      inetutils-ping inetutils-tools \
      jq \
      logrotate \
      libssh2-1 lynx \
      net-tools \
      mysql-client \
      postgresql-client \
      openssl \
      procps psmisc \
      rsync rsyslog \
      software-properties-common ssl-cert strace sudo supervisor \
      tar telnet thefuck tmux traceroute tree \
      unzip \
      wget whois \
      vim \
      xz-utils \
      zsh zsh-syntax-highlighting && \
    apt -o Acquire::http::proxy="$PROXY" install -qy \
      rsyslog-elasticsearch && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

#    apt -o Acquire::http::proxy="$PROXY" install -qy --force-yes \
#      ripgrep && \

RUN mkdir -p /root/src/exa && \
    EXA_FILE_NAME=$(curl -sL https://api.github.com/repos/ogham/exa/releases/latest | jq -r '.assets[].browser_download_url' | grep linux) && \
    wget -O "/root/src/exa/exa-linux-x86_64.zip" "${EXA_FILE_NAME}" && \
    cd /root/src/exa/ && \
    unzip exa-linux-x86_64.zip && \
    mv /root/src/exa/exa-linux-x86_64 /usr/local/bin/exa && \
    chmod 0755 /usr/local/bin/exa && \
    rm -rf /root/src/exa

RUN apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -o Acquire::http::proxy="$PROXY" -y install \
      libmcrypt4 libmcrypt-dev \
      libzstd1 libzstd-dev \
      php-imagick \
      php-ssh2 \
      php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-common php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-gd php${PHP_VERSION}-gmp \
      php${PHP_VERSION}-intl \
      php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-json \
      php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-pgsql \
      php${PHP_VERSION}-soap php${PHP_VERSION}-sqlite3 \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-zip \
    && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    apt -o Acquire::http::proxy="$PROXY" install -y \
      php-pear \
      pear-channels \
      && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

## To get this to also build older versions of PHP have to do some testing on versions here

ADD ./files/php/20-igbinary.ini "/etc/php/${PHP_VERSION}/mods-available/20-igbinary.ini"
ADD ./files/php/10-xdebug.ini "/etc/php/${PHP_VERSION}/mods-available/10-xdebug.ini"


## Finish with true deal is test non match
## Run if not 5.6 and 7.1
RUN test "${PHP_VERSION}" != "5.6" && test "${PHP_VERSION}" != "7.1" && \
    yes | pecl install -f igbinary && \
    yes | pecl install -f redis && \
    yes | pecl install -f mcrypt && \
    yes | pecl install -f xdebug && \
    echo "extension=$(find /usr/lib/php -iname redis.so | sort -n -r  | head -n 1)" > "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" && \
    echo "extension=$(find /usr/lib/php -iname mcrypt.so | sort -n -r  | head -n 1)" > "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" && \
    XDEBUG_LOCATION='zend_extension="'$(find /usr/lib/php -iname xdebug.so | sort -n -r  | head -n 1)'"' && \
    sed -i -E -e "s|zend_extension.+|${XDEBUG_LOCATION}|" "/etc/php/${PHP_VERSION}/mods-available/10-xdebug.ini" && \
    IGBINARY_LOCATION='extension="'$(find /usr/lib/php -iname igbinary.so | sort -n -r  | head -n 1)'"' && \
    sed -i -E -e "s|extension.+|${IGBINARY_LOCATION}|" "/etc/php/${PHP_VERSION}/mods-available/20-igbinary.ini" || \
      true

## Finish with true deal is test non match
## Run if is 5.6 or 7.1
RUN test "${PHP_VERSION}" = '5.6' || test "${PHP_VERSION}" = '7.1' && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -o Acquire::http::proxy="$PROXY" -y install \
      php-redis \
      php-igbinary \
      php-xdebug \
      php${PHP_VERSION}-mcrypt \
    && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* && \
    echo "extension=redis.so" > "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" && \
    echo "extension=mcrypt.so" > "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" || \
      true

## Finish with true to deal with files not being there
## Move system files to back up just in case
RUN mkdir -p "/etc/php/${PHP_VERSION}/mods-available/bak" && \
    mv "/etc/php/${PHP_VERSION}/mods-available/redis.ini*" "/etc/php/${PHP_VERSION}/mods-available/bak/" 2>/dev/null && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" "/etc/php/${PHP_VERSION}/mods-available/redis.ini" && \
    mv "/etc/php/${PHP_VERSION}/mods-available/mcrypt.ini*" "/etc/php/${PHP_VERSION}/mods-available/bak/" 2>/dev/null && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" "/etc/php/${PHP_VERSION}/mods-available/mcrypt.ini" && \
    mv "/etc/php/${PHP_VERSION}/mods-available/igbinary.ini*" "/etc/php/${PHP_VERSION}/mods-available/bak/" 2>/dev/null && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-igbinary.ini" "/etc/php/${PHP_VERSION}/mods-available/igbinary.ini" && \
    mv "/etc/php/${PHP_VERSION}/mods-available/xdebug.ini*" "/etc/php/${PHP_VERSION}/mods-available/bak/" 2>/dev/null && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/10-xdebug.ini" "/etc/php/${PHP_VERSION}/mods-available/xdebug.ini" || \
      true

RUN find "/etc/php/${PHP_VERSION}/fpm" -iname '*xdebug*' -delete && \
    find "/etc/php/${PHP_VERSION}/cli" -iname '*xdebug*' -delete && \
    find "/etc/php/${PHP_VERSION}/fpm" -iname '*redis*' -delete && \
    find "/etc/php/${PHP_VERSION}/cli" -iname '*redis*' -delete && \
    find "/etc/php/${PHP_VERSION}/fpm" -iname '*igbinary*' -delete && \
    find "/etc/php/${PHP_VERSION}/cli" -iname '*igbinary*' -delete && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-igbinary.ini" "/etc/php/${PHP_VERSION}/cli/conf.d/20-igbinary.ini" && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-igbinary.ini" "/etc/php/${PHP_VERSION}/fpm/conf.d/20-igbinary.ini" && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" "/etc/php/${PHP_VERSION}/cli/conf.d/20-redis.ini" && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-redis.ini" "/etc/php/${PHP_VERSION}/fpm/conf.d/20-redis.ini" && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" "/etc/php/${PHP_VERSION}/cli/conf.d/20-mcrypt.ini" && \
    ln -sf "/etc/php/${PHP_VERSION}/mods-available/20-mcrypt.ini" "/etc/php/${PHP_VERSION}/fpm/conf.d/20-mcrypt.ini"

ENV PHP_TIMEZONE="Africa/Johannesburg" \
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
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_REVALIDATE_FREQ="1" \
    PHP_OPCACHE_PRELOAD_FILE="" \
    COMPOSER_PROCESS_TIMEOUT=2000

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
        -e "s/expose_phpexpose_php = On/expose_php = Off/" \
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
        /etc/php/${PHP_VERSION}/cli/php.ini \
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

#        -e 's/listen = .*/listen = 9000/' \

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN composer config --global process-timeout "${COMPOSER_PROCESS_TIMEOUT}" && \
    composer global require hirak/prestissimo

RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O /rclone-current-linux-amd64.zip && \
    unzip /rclone-current-linux-amd64.zip -d / && \
    mv /rclone-v* /rclone && \
    cp /rclone/rclone /usr/local/bin/ && \
    rm -rf /rclone* && \
    apt -o Acquire::http::proxy="$PROXY" -y update && \
    apt -o Acquire::http::proxy="$PROXY" dist-upgrade  -y && \
    apt -o Acquire::http::proxy="$PROXY" install -y fuse && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
RUN add-apt-repository -y ppa:git-core/ppa && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -o Acquire::http::proxy="$PROXY" install -qy git-lfs && \
    git lfs install && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ADD ./files/zshrc/zshrc.in /root/.zshrc

#    echo "web:`date +%s | sha256sum | base64 | head -c 32`" | chpasswd && \
RUN adduser --home /site --uid 1000 --gecos "" --disabled-password --shell /bin/bash web && \
    usermod -a -G tty web && \
    mkdir -p /site/web && \
    mkdir -p /site/logs/php && \
    mkdir -p /site/logs/supervisor && \
    find /site -not -user web -execdir chown "web:" {} \+

ADD ./files/GeoIp/GeoIP.conf /etc/GeoIP.conf
ADD ./files/GeoIp /usr/share/GeoIP

# Fix for no missing repository
RUN cd /usr/share/GeoIP/ && \
    apt -o Acquire::http::proxy="$PROXY" update && \
    /usr/bin/tar -xJpvf GeoIp.tar.xz && \
    apt -o Acquire::http::proxy="$PROXY" -o Dpkg::Options::="--force-confold" -y install \
        geoip-bin geoip-database geoipupdate && \
    chown -R web:web /usr/share/GeoIP/* && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

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
ADD ./files/supervisord.conf /supervisord.conf

ADD ./files/rsyslog.conf /etc/rsyslog.conf
ADD ./files/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf
ADD ./files/artisan-bash-prompt /etc/bash_completion.d/artisan-bash-prompt
ADD ./files/composer-bash-prompt /etc/bash_completion.d/composer-bash-prompt
ADD ./files/run_with_env.sh /bin/run_with_env.sh

RUN echo 'shopt -s histappend\n\
    PROMPT_COMMAND="history -a;$PROMPT_COMMAND"\n' >> /site/.bashrc && \
    echo 'cd /site/web' >> /site/.bashrc && \
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

#add-apt-repository --yes --no-update ppa:nginx/stable && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B3981E7A6852F782CC4951600A6F0A3C300EE8C && \

RUN apt -o Acquire::http::proxy="$PROXY" update && \
    apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
    apt -o Acquire::http::proxy="$PROXY" -y install \
          nginx-extras \
        && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ADD ./files/nginx_config /site/nginx/config

RUN mkdir -p /site/logs/nginx && \
    mkdir -p /var/lib/nginx && \
    find /var/lib/nginx -not -user web -execdir chown "web:" {} \+

ADD ./files/testLoop.sh /testLoop.sh
RUN chmod u+x /testLoop.sh

USER web

RUN composer config --global process-timeout "${COMPOSER_PROCESS_TIMEOUT}" && \
    composer global require hirak/prestissimo && \
    rm -rf /site/web/vendor

USER root

RUN /usr/bin/geoipupdate -v --config-file /etc/GeoIP.conf -d /usr/share/GeoIP && \
    chown -R web: /usr/share/GeoIP/*

ADD ./files/logrotate.d/ /etc/logrotate.d/

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" > /etc/apt/sources.list.d/elastic.list && \
    apt -o Acquire::http::proxy="$PROXY" update && \
        apt -o Acquire::http::proxy="$PROXY" -qy dist-upgrade && \
        apt -o Acquire::http::proxy="$PROXY" install -qy \
        filebeat \
        metricbeat && \
    apt -y autoremove && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/*

ADD ./files/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
ADD ./files/filebeat/modules.d/nginx.yml /etc/filebeat/modules.d/nginx.yml
ADD ./files/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml
ADD ./files/metricbeat/modules.d/nginx.yml /etc/metricbeat/modules.d/nginx.yml
ADD ./files/metricbeat/modules.d/php_fpm.yml /etc/metricbeat/modules.d/php_fpm.yml

RUN find /site -not -user web -execdir chown "web:" {} \+ && \
    find /usr/share/GeoIP -not -user web -execdir chown "web:" {} \+

RUN chmod -R a+w /dev/stdout && \
    chmod -R a+w /dev/stderr && \
    chmod -R a+w /dev/stdin && \
    usermod -a -G tty syslog && \
    usermod -a -G tty web

EXPOSE 80

ENV NGINX_SITES='locahost' \
    CRONTAB_ACTIVE="FALSE" \
    WEBSOCKET_ACTIVE="FALSE" \
    ENABLE_DEBUG="TRUE" \
    GEN_LV_ENV="FALSE" \
    INITIALISE_FILE="/site/web/initialise.sh" \
    LV_DO_CACHING="FALSE"

CMD ["/start.sh"]
