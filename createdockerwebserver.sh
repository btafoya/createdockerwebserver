#!/bin/bash

# Configuration variables
WEB_SERVER_PORT=${1:-8080}
PHP_VERSION=${2:-7.4}
GIT_REPO_URL=${3:-"https://github.com/your-repo/your-project.git"}
PROJECT_DIR=${4:-"/var/www/html"}
WEB_ROOT=${5:-"public"}
PHP_EXTENSIONS=${6:-"apc bcmath intl cli fpm curl imap imagick gd mysql zip xml soap ssh2 gearman redis apcu mbstring mongodb mailparse tidy gmp sqlite3 mcrypt dev xdebug pgsql opcache gearman maxmind2"}
MYSQL_ROOT_PASSWORD=${7:-$(openssl rand -base64 12)}
MYSQL_DATABASE=${8:-"example_db"}
MYSQL_USER=${9:-"example_user"}
MYSQL_PASSWORD=${10:-$(openssl rand -base64 12)}

# Directories
CONFIG_DIR="configs"
WEBROOT_DIR="webroot"
MYSQLDATA_DIR="mysqldata"
LOGS_DIR="logs"

# Function to display help
show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -p, --port            Web server port (default: 8080)
  -v, --php-version     PHP version (default: 7.4)
  -g, --git-repo        Git repository URL (default: https://github.com/your-repo/your-project.git)
  -d, --project-dir     Project directory (default: /var/www/html)
  -r, --web-root        Web root directory (default: public)
  -e, --php-extensions  PHP extensions (default: apc bcmath intl cli fpm curl imap imagick gd mysql zip xml soap ssh2 gearman redis apcu mbstring mongodb mailparse tidy gmp sqlite3 mcrypt dev xdebug pgsql opcache gearman maxmind2)
  -m, --mysql-root-pw   MySQL root password (default: generated)
  -b, --mysql-db        MySQL database name (default: example_db)
  -u, --mysql-user      MySQL user (default: example_user)
  -w, --mysql-pw        MySQL user password (default: generated)
  -h, --help            Show this help message
  -i, --interactive     Interactive setup
  -c, --git-command     Git command to execute (e.g., git pull)
  -u, --update-php      Update PHP version on an already deployed stack

Examples:
  $0 -p 8080 -v 7.4 -g https://github.com/your-repo/your-project.git -d /var/www/html -r public -m example_root_password -b example_db -u example_user -w example_pass
  $0 -i
  $0 -c "git pull"
  $0 -u 8.0
EOF
}

# Function to check if Docker is installed
check_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "Docker is not installed. Installing Docker..."
        install_docker
    fi
}

# Function to install Docker
install_docker() {
    # Update system and install required packages to handle HTTPS over APT
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Remove any older versions of Docker that might be installed
    sudo apt remove -y docker docker-engine docker.io containerd runc

    # Add Docker’s official GPG key to ensure integrity of the packages
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker's stable repository for Ubuntu based on the system architecture
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update apt packages list with the new Docker repository included
    sudo apt update

    # Install Docker Community Edition, CLI, and containerd.io along with Docker Compose Plugin
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

# Function to clone the git repository
clone_repo() {
    if [ -d "$WEBROOT_DIR/$WEB_ROOT" ]; then
        echo "Web root directory already exists. Skipping clone."
    else
        git clone "$GIT_REPO_URL" "$WEBROOT_DIR/$WEB_ROOT"
    fi
}

# Function to execute a git command
execute_git_command() {
    if [ -n "$GIT_COMMAND" ]; then
        cd "$WEBROOT_DIR/$WEB_ROOT"
        eval "$GIT_COMMAND"
        cd -
    fi
}

# Function to create Docker Compose file
create_docker_compose() {
    cat <<EOF > docker-compose.yml
version: '3'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "${WEB_SERVER_PORT}:80"
    volumes:
      - ./${WEBROOT_DIR}:/var/www/html
      - ./${CONFIG_DIR}/apache2:/etc/apache2
      - ./${CONFIG_DIR}/php.ini:/usr/local/etc/php/php.ini
      - ./${LOGS_DIR}/apache2:/var/log/apache2
    depends_on:
      - db
      - gearman
    environment:
      - COMPOSER_HOME=/var/www/html

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - ./${MYSQLDATA_DIR}:/var/lib/mysql
      - ./${CONFIG_DIR}/my.cnf:/etc/mysql/my.cnf
      - ./${LOGS_DIR}/mysql:/var/log/mysql
    profiles:
      - donotstart

  gearman:
    image: gearman
    ports:
      - "4730:4730"
    profiles:
      - donotstart

  composer:
    image: composer:latest
    volumes:
      - ./${WEBROOT_DIR}:/app
    working_dir: /app
    command: composer install

  supervisor:
    build:
      context: .
      dockerfile: Dockerfile.supervisor
    volumes:
      - ./${WEBROOT_DIR}:/var/www/html
      - ./${CONFIG_DIR}/supervisord.conf:/etc/supervisor/conf.d/supervisord.conf
      - ./${LOGS_DIR}/supervisor:/var/log/supervisor
    depends_on:
      - gearman
    profiles:
      - donotstart

volumes:
  db_data:
EOF
}

# Function to create Dockerfile for PHP with extensions
create_dockerfile() {
    cat <<EOF > Dockerfile
FROM php:${PHP_VERSION}-apache
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    libicu-dev \
    libonig-dev \
    libzip-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libpq-dev \
    libgearman-dev \
    libmemcached-dev \
    libssh2-1-dev \
    libsqlite3-dev \
    libgmp-dev \
    libtidy-dev \
    libmagickwand-dev \
    libmongoc-dev \
    libmaxminddb-dev \
    && docker-php-ext-install ${PHP_EXTENSIONS} \
    && pecl install gearman \
    && docker-php-ext-enable gearman \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && pecl install mailparse \
    && docker-php-ext-enable mailparse \
    && pecl install maxminddb \
    && docker-php-ext-enable maxminddb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the web root
RUN sed -i "s|/var/www/html|/var/www/html/${WEB_ROOT}|g" /etc/apache2/sites-available/000-default.conf
EOF
}

# Function to create Dockerfile for Supervisor
create_supervisor_dockerfile() {
    cat <<EOF > Dockerfile.supervisor
FROM php:${PHP_VERSION}-cli
RUN apt-get update && apt-get install -y supervisor
CMD ["supervisord", "-n"]
EOF
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
<VirtualHost *:80>
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
mysqli.default_port = 3306
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

[mysqld_safe]
log-error=/var/log/mysql/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
}

# Function for interactive setup
interactive_setup() {
    read -p "Enter web server port (default: 8080): " WEB_SERVER_PORT
    WEB_SERVER_PORT=${WEB_SERVER_PORT:-8080}

    read -p "Enter PHP version (default: 7.4): " PHP_VERSION
    PHP_VERSION=${PHP_VERSION:-7.4}

    read -p "Enter Git repository URL (default: https://github.com/your-repo/your-project.git): " GIT_REPO_URL
    GIT_REPO_URL=${GIT_REPO_URL:-"https://github.com/your-repo/your-project.git"}

    read -p "Enter project directory (default: /var/www/html): " PROJECT_DIR
    PROJECT_DIR=${PROJECT_DIR:-"/var/www/html"}

    read -p "Enter web root directory (default: public): " WEB_ROOT
    WEB_ROOT=${WEB_ROOT:-"public"}

    read -p "Enter PHP extensions (default: apc bcmath intl cli fpm curl imap imagick gd mysql zip xml soap ssh2 gearman redis apcu mbstring mongodb mailparse tidy gmp sqlite3 mcrypt dev xdebug pgsql opcache gearman maxmind2): " PHP_EXTENSIONS
    PHP_EXTENSIONS=${PHP_EXTENSIONS:-"apc bcmath intl cli fpm curl imap imagick gd mysql zip xml soap ssh2 gearman redis apcu mbstring mongodb mailparse tidy gmp sqlite3 mcrypt dev xdebug pgsql opcache gearman maxmind2"}

    read -p "Enter MySQL root password (default: generated): " MYSQL_ROOT_PASSWORD
    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-$(openssl rand -base64 12)}

    read -p "Enter MySQL database name (default: example_db): " MYSQL_DATABASE
    MYSQL_DATABASE=${MYSQL_DATABASE:-"example_db"}

    read -p "Enter MySQL user (default: example_user): " MYSQL_USER
    MYSQL_USER=${MYSQL_USER:-"example_user"}

    read -p "Enter MySQL user password (default: generated): " MYSQL_PASSWORD
    MYSQL_PASSWORD=${MYSQL_PASSWORD:-$(openssl rand -base64 12)}
}

# Function to update PHP version
update_php_version() {
    read -p "Enter new PHP version: " NEW_PHP_VERSION
    PHP_VERSION=$NEW_PHP_VERSION
    create_dockerfile
    create_supervisor_dockerfile
    docker-compose build
    docker-compose up -d
    echo "PHP version updated to $NEW_PHP_VERSION."
}

# Function to write credentials to a file
write_credentials() {
    cat <<EOF > credentials.txt
Web Server Port: $WEB_SERVER_PORT
PHP Version: $PHP_VERSION
Git Repository URL: $GIT_REPO_URL
Project Directory: $PROJECT_DIR
Web Root Directory: $WEB_ROOT
PHP Extensions: $PHP_EXTENSIONS
MySQL Root Password: $MYSQL_ROOT_PASSWORD
MySQL Database: $MYSQL_DATABASE
MySQL User: $MYSQL_USER
MySQL Password: $MYSQL_PASSWORD
EOF
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--port) WEB_SERVER_PORT="$2"; shift ;;
        -v|--php-version) PHP_VERSION="$2"; shift ;;
        -g|--git-repo) GIT_REPO_URL="$2"; shift ;;
        -d|--project-dir) PROJECT_DIR="$2"; shift ;;
        -r|--web-root) WEB_ROOT="$2"; shift ;;
        -e|--php-extensions) PHP_EXTENSIONS="$2"; shift ;;
        -m|--mysql-root-pw) MYSQL_ROOT_PASSWORD="$2"; shift ;;
        -b|--mysql-db) MYSQL_DATABASE="$2"; shift ;;
        -u|--mysql-user) MYSQL_USER="$2"; shift ;;
        -w|--mysql-pw) MYSQL_PASSWORD="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        -i|--interactive) interactive_setup; shift ;;
        -c|--git-command) GIT_COMMAND="$2"; shift ;;
        -u|--update-php) update_php_version; shift ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Main script execution
check_docker
mkdir -p "${WEBROOT_DIR}"
mkdir -p "${MYSQLDATA_DIR}"
mkdir -p "${LOGS_DIR}"
clone_repo
execute_git_command
create_docker_compose
create_dockerfile
create_supervisor_dockerfile
create_supervisor_conf
create_apache_config_dir
create_php_ini
create_my_cnf
write_credentials
