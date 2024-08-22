# Create Docker Web Server

This repository contains a script to set up a Dockerized web server with PHP and MySQL, including configuration for Apache, PHP extensions, and Supervisor. This script is designed to run on Debian based distros.

## Features

- **Dockerized Environment**: Run your web server in a containerized environment.
- **PHP Extensions**: Easily configure and install PHP extensions.
- **MySQL Database**: Set up a MySQL database with customizable credentials.
- **Supervisor**: Manage background processes with Supervisor.
- **Interactive Setup**: Optionally configure the setup interactively.
- **Git Integration**: Clone a Git repository into the web root.

## Prerequisites

- Docker
- Git

## Usage

### Command-Line Options

```bash
Usage: createdockerwebserver.sh [options]

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
  createdockerwebserver.sh -p 8080 -v 7.4 -g https://github.com/your-repo/your-project.git -d /var/www/html -r public -m example_root_password -b example_db -u example_user -w example_pass
  createdockerwebserver.sh -i
  createdockerwebserver.sh -c "git pull"
  createdockerwebserver.sh -u 8.0
```

### Interactive Setup

Run the script with the `-i` or `--interactive` flag to set up the environment interactively.

```bash
chmod a+x createdockerwebserver.sh
./createdockerwebserver.sh -i
```

### Update PHP Version

To update the PHP version on an already deployed stack, use the `-u` or `--update-php` flag.

```bash
./createdockerwebserver.sh -u 8.0
```

## Directory Structure

- **configs**: Directory for configuration files.
- **webroot**: Directory for the web root.
- **mysqldata**: Directory for MySQL data.
- **logs**: Directory for logs.

## Files Created

- **docker-compose.yml**: Docker Compose file for setting up the services.
- **Dockerfile**: Dockerfile for the PHP and Apache service.
- **Dockerfile.supervisor**: Dockerfile for the Supervisor service.
- **configs/supervisord.conf**: Supervisor configuration file.
- **configs/apache2/000-default.conf**: Apache configuration file.
- **configs/php.ini**: PHP configuration file.
- **configs/my.cnf**: MySQL configuration file.
- **credentials.txt**: File containing the credentials and configuration used.

## Contributing

Feel free to open issues or pull requests if you have any suggestions or improvements.

## License

This project is licensed under the MIT License.

## Contact

Brian Tafoya - btafoya@briantafoya.com

Project Link: [https://github.com/btafoya/createdockerwebserver](https://github.com/btafoya/createdockerwebserver)
