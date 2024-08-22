#!/bin/bash

# Configuration directory
CONFIG_DIR="config"
WEB_ROOT="web_root"
MYSQL_DATA="mysql_data"

# Function to check if a port is available
is_port_available() {
    local port=$1
    if lsof -i :$port -sTCP:LISTEN -t >/dev/null ; then
        return 1
    else
        return 0
    fi
}

# Function to create Supervisor configuration file
create_supervisor_conf() {
    mkdir -p "${CONFIG_DIR}"
    cat <<EOF > ${CONFIG_DIR}/supervisord.conf
[supervisord]
nodaemon=true

[program:gearman-worker]
command=php /var/www/html/${WEB_ROOT}/worker.php
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/gearman-worker.err.log
stdout_logfile=/var/log/supervisor/gearman-worker.out.log
EOF
}

# Function to create Apache configuration directory
create_apache_config_dir() {
    mkdir -p "${CONFIG_DIR}/apache2"
    cat <<EOF > ${CONFIG_DIR}/apache2/000-default.conf
<VirtualHost *:${WEB_PORT}>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/${WEB_ROOT}

    <Directory /var/www/html/${WEB_ROOT}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
}

# Function to create PHP configuration file
create_php_ini() {
    mkdir -p "${CONFIG_DIR}"
    cat <<EOF > ${CONFIG_DIR}/php.ini
[PHP]
engine = On
short_open_tag = On
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions =
disable_classes =
zend.enable_gc = On
expose_php = Off
max_execution_time = 90
max_input_time = 60
max_input_vars = 10007
memory_limit = 256M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = On
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = Off
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 68M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = 62M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
[CLI Server]
cli_server.color = On
[Date]
date.timezone=${TIMEZONE}
[filter]
[iconv]
[intl]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.default_socket=
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = Off
[SQL]
sql.safe_mode = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.default_port = ${MYSQL_PORT}
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[Sybase-CT]
sybct.allow_persistent = On
sybct.max_persistent = -1
sybct.max_links = -1
sybct.min_server_severity = 10
sybct.min_client_severity = 10
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
session.save_handler = files
session.save_path = "/var/lib/php/sessions"
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.sid_bits_per_character = 5
[Assertion]
zend.assertions = -1
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = Off
[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[dba]
[opcache]
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=2
opcache.revalidate_path=0
opcache.save_comments=1
opcache.enable_file_override=0
opcache.optimization_level=0xffffffff
opcache.inherited_hack=1
opcache.dups_fix=0
opcache.blacklist_filename=
opcache.max_file_size=0
opcache.consistency_checks=0
opcache.force_restart_timeout=180
opcache.error_log=
opcache.log_verbosity_level=1
opcache.preferred_memory_model=
opcache.protect_memory=0
opcache.mmap_base=
opcache.lockfile_path=/tmp
opcache.file_cache=
opcache.file_cache_only=0
opcache.file_cache_consistency_checks=1
opcache.file_cache_fallback=1
opcache.huge_code_pages=1
opcache.validate_permission=0
opcache.validate_root=0
opcache.file_update_protection=2
opcache.record_warnings=0
opcache.restrict_api=
opcache.validate_permission=0
opcache.validate_root=0
opcache.file_update_protection=2
opcache.record_warnings=0
opcache.restrict_api=
[curl]
[openssl]
EOF
}

# Function to create MySQL configuration file
create_my_cnf() {
    mkdir -p "${CONFIG_DIR}"
    cat <<EOF > ${CONFIG_DIR}/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
symbolic-links=0
port=${MYSQL_PORT}
bind-address=0.0.0.0

[mysqld_safe]
log-error=/var/log/mysql/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
}

# Function to create Dockerfile
create_dockerfile() {
    cat <<EOF > Dockerfile
# Use the official Ubuntu ${UBUNTU_VERSION} image as the base image
FROM ubuntu:${UBUNTU_VERSION}

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Add required repositories
RUN apt-get update && \\
    apt-get install -y software-properties-common && \\
    add-apt-repository ppa:ondrej/php -y && \\
    add-apt-repository ppa:ondrej/apache2 -y && \\
    apt-get update

# Install required packages
RUN apt-get install -y \\
    apache2 \\
    mysql-server \\
    redis-server \\
    supervisor \\
    gearman-job-server \\
    php${PHP_VERSION}-apc \\
    php${PHP_VERSION}-bcmath \\
    php${PHP_VERSION}-intl \\
    php${PHP_VERSION}-cli \\
    php${PHP_VERSION}-curl \\
    php${PHP_VERSION}-imap \\
    php${PHP_VERSION}-imagick \\
    php${PHP_VERSION}-gd \\
    php${PHP_VERSION}-mysql \\
    php${PHP_VERSION}-zip \\
    php${PHP_VERSION}-xml \\
    php${PHP_VERSION}-soap \\
    php${PHP_VERSION}-ssh2 \\
    php${PHP_VERSION}-gearman \\
    php${PHP_VERSION}-redis \\
    php${PHP_VERSION}-apcu \\
    php${PHP_VERSION}-mbstring \\
    php${PHP_VERSION}-mongodb \\
    php${PHP_VERSION}-mailparse \\
    php${PHP_VERSION}-tidy \\
    php${PHP_VERSION}-gmp \\
    php${PHP_VERSION}-sqlite3 \\
    php${PHP_VERSION}-mcrypt \\
    php${PHP_VERSION}-dev \\
    php${PHP_VERSION}-xdebug \\
    php${PHP_VERSION}-pgsql \\
    php${PHP_VERSION}-opcache \\
    php${PHP_VERSION}-iconv \\
    php${PHP_VERSION}-maxminddb \\
    php-pear

# Enable Apache modules
RUN a2enmod access_compat actions alias auth_basic authn_core authn_file authz_core authz_host authz_user autoindex cgid deflate dir env expires fcgid filter headers include mime mpm_event negotiation proxy_ajp proxy_balancer proxy_fcgi proxy_http proxy reqtimeout rewrite setenvif slotmem_shm socache_shmcb

# Set MySQL root password and create database and user
RUN echo "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections && \\
    echo "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections && \\
    apt-get install -y mysql-server && \\
    service mysql start && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${MYSQL_DATABASE};" && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';" && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" && \\
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

# Expose ports
EXPOSE ${WEB_PORT} ${MYSQL_PORT}

# Set up persistent volumes
VOLUME ["/var/www/html", "/etc/apache2", "/etc/mysql", "/etc/supervisor", "/etc/php/\${PHP_VERSION}/apache2"]

# Copy configuration files
COPY ${CONFIG_DIR}/supervisord.conf /etc/supervisor/supervisord.conf
COPY ${CONFIG_DIR}/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY ${CONFIG_DIR}/php.ini /etc/php/\${PHP_VERSION}/apache2/php.ini
COPY ${CONFIG_DIR}/my.cnf /etc/mysql/my.cnf

# Start services
CMD ["/usr/bin/supervisord"]
EOF
}

# Function to create docker-compose.yml
create_docker_compose() {
    cat <<EOF > docker-compose.yml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        PHP_VERSION: \${PHP_VERSION}
        MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
        MYSQL_DATABASE: \${MYSQL_DATABASE}
        MYSQL_USER: \${MYSQL_USER}
        MYSQL_PASSWORD: \${MYSQL_PASSWORD}
        WEB_PORT: \${WEB_PORT}
        MYSQL_PORT: \${MYSQL_PORT}
        UBUNTU_VERSION: \${UBUNTU_VERSION}
    ports:
      - "\${WEB_PORT}:${WEB_PORT}"
      - "\${MYSQL_PORT}:${MYSQL_PORT}"
    volumes:
      - ./${CONFIG_DIR}/apache2/000-default.conf:/etc/apache2/sites-available/000-default.conf
      - ./${CONFIG_DIR}/supervisord.conf:/etc/supervisor/supervisord.conf
      - ./${CONFIG_DIR}/php.ini:/etc/php/\${PHP_VERSION}/apache2/php.ini
      - ./${CONFIG_DIR}/my.cnf:/etc/mysql/my.cnf
      - ./${MYSQL_DATA}:/var/lib/mysql
      - ./${WEB_ROOT}:/var/www/html
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${MYSQL_DATABASE}
      MYSQL_USER: \${MYSQL_USER}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD}
EOF
}

# Interactive configuration for PHP version
echo "Select PHP version:"
select php_version in 5.6 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3; do
    case $php_version in
        5.6|7.1|7.2|7.3|7.4|8.0|8.1|8.2|8.3)
            export PHP_VERSION=$php_version
            break
            ;;
        *)
            echo "Invalid option. Please select a valid PHP version."
            ;;
    esac
done

# Interactive configuration for Ubuntu version
echo "Select Ubuntu version:"
select ubuntu_version in 24.04 22.04 20.04; do
    case $ubuntu_version in
        24.04|22.04|20.04)
            export UBUNTU_VERSION=$ubuntu_version
            break
            ;;
        *)
            echo "Invalid option. Please select a valid Ubuntu version."
            ;;
    esac
done

# Interactive configuration for MySQL credentials
read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
read -p "Enter MySQL database name: " MYSQL_DATABASE
read -p "Enter MySQL user: " MYSQL_USER
read -p "Enter MySQL user password: " MYSQL_PASSWORD

# Interactive configuration for ports
while true; do
    read -p "Enter web port (default 8080): " WEB_PORT
    WEB_PORT=${WEB_PORT:-8080}
    if is_port_available $WEB_PORT; then
        echo "Port $WEB_PORT is available."
        break
    else
        echo "Port $WEB_PORT is not available. Please choose another port."
    fi
done

while true; do
    read -p "Enter MySQL port (default 3306): " MYSQL_PORT
    MYSQL_PORT=${MYSQL_PORT:-3306}
    if is_port_available $MYSQL_PORT; then
        echo "Port $MYSQL_PORT is available."
        break
    else
        echo "Port $MYSQL_PORT is not available. Please choose another port."
    fi
done

# Interactive configuration for timezone
echo "Select timezone (default America/New_York):"
select timezone in America/New_York America/Los_Angeles America/Chicago America/Denver America/Phoenix America/Anchorage America/Juneau America/Detroit America/Indiana/Indianapolis America/Indiana/Marengo America/Indiana/Knox America/Indiana/Vevay America/Indiana/Tell_City America/Indiana/Petersburg America/Indiana/Vincennes America/Indiana/Winamac America/Indiana/Marengo America/Kentucky/Monticello America/Kentucky/Louisville America/North_Dakota/Center America/North_Dakota/New_Salem America/North_Dakota/Beulah America/North_Dakota/Center America/North_Dakota/New_Salem America/North_Dakota/Beulah; do
    case $timezone in
        America/New_York|America/Los_Angeles|America/Chicago|America/Denver|America/Phoenix|America/Anchorage|America/Juneau|America/Detroit|America/Indiana/Indianapolis|America/Indiana/Marengo|America/Indiana/Knox|America/Indiana/Vevay|America/Indiana/Tell_City|America/Indiana/Petersburg|America/Indiana/Vincennes|America/Indiana/Winamac|America/Kentucky/Monticello|America/Kentucky/Louisville|America/North_Dakota/Center|America/North_Dakota/New_Salem|America/North_Dakota/Beulah)
            export TIMEZONE=$timezone
            break
            ;;
        *)
            echo "Invalid option. Please select a valid timezone."
            ;;
    esac
done

# Write credentials to a file
cat <<EOF > .env
PHP_VERSION=${PHP_VERSION}
UBUNTU_VERSION=${UBUNTU_VERSION}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
WEB_PORT=${WEB_PORT}
MYSQL_PORT=${MYSQL_PORT}
TIMEZONE=${TIMEZONE}
EOF

# Create configuration files
create_supervisor_conf
create_apache_config_dir
create_php_ini
create_my_cnf
create_dockerfile
create_docker_compose

# Create the web_root directory and index.php file
mkdir -p "${WEB_ROOT}"
cat <<EOF > ${WEB_ROOT}/index.php
<?php
phpinfo();
?>
EOF

# Create the mysql_data directory
mkdir -p "${MYSQL_DATA}"

# Build the Docker image
docker compose build

# Run the Docker container
docker compose up -d
