# Create Docker Web Server

This repository contains a script to set up a Dockerized web server with PHP and MySQL, including configuration for Apache, PHP extensions, and Supervisor.

## Features

- **Dockerized Environment**: Run your web server in a containerized environment.
- **PHP Extensions**: Easily configure and install PHP extensions.
- **MySQL Database**: Set up a MySQL database with customizable credentials.
- **Supervisor**: Manage background processes with Supervisor.
- **Interactive Setup**: Optionally configure the setup interactively.
- **Git Integration**: Clone a Git repository into the web root.

## Prerequisites

- Debian based Distro as Docker Host
- Docker & Docker Compose
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
