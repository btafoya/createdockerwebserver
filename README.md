# Create Docker Web Server

This repository contains a script to set up a web application environment on a Ubuntu based, with Apache, PHP, MySQL, PHP (5.6 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3), PHP extensions, Redis, Gearman Job Server, and Supervisor.

<a href="https://www.buymeacoffee.com/luckyedward"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me Drink&emoji=🍹&slug=luckyedward&button_colour=5F7FFF&font_colour=ffffff&font_family=Bree&outline_colour=000000&coffee_colour=FFDD00" style="float: right;" /></a>

## Features

- **Dockerized Environment**: Run your web server in a containerized environment.
- **PHP Extensions**: Easily configure and install PHP extensions.
- **MySQL Database**: Set up a MySQL database with customizable credentials.
- **Supervisor**: Manage background processes with Supervisor.
- **Interactive Setup**: Optionally configure the setup interactively.

## Prerequisites

- Debian based Distro as Docker Host
- Docker & Docker Compose
- Git

This script sets up a Dockerized web application environment with Apache, PHP, MySQL, and Supervisor.

## Features

- Interactive configuration for PHP version, MySQL credentials, and ports.
- Stores MySQL data outside of the Docker image.
- Generates Dockerfile and docker-compose.yml.
- Builds and runs the Docker container.

## Prerequisites

- Docker
- Docker Compose

## Usage

1. Make the script executable:

    ```bash
    chmod +x createdockerwebserver.sh
    ```

2. Run the script:

    ```bash
    ./createdockerwebserver.sh
    ```

3. Follow the interactive prompts to configure PHP version, MySQL credentials, and ports.

## Configuration

- **PHP Version**: Select from the list of available versions.
- **MySQL Credentials**: Enter root password, database name, user, and user password.
- **Ports**: Enter web port (default 80) and MySQL port (default 3306).

## Directory Structure

- `config`: Directory for configuration files.
- `web_root`: Directory for web application files.
- `mysql_data`: Directory for MySQL data.

## Files

- `Dockerfile`: Dockerfile for building the Docker image.
- `docker-compose.yml`: Docker Compose file for running the Docker container.
- `credentials.env`: File containing the configuration values.

## Commands

- **Build the Docker image**:

    ```bash
    docker compose build
    ```

- **Run the Docker container**:

    ```bash
    docker compose up -d
    ```

## Contributing

Feel free to open issues or pull requests if you have any suggestions or improvements.

## License

This project is licensed under the MIT License.

## Contact

Brian Tafoya - btafoya@briantafoya.com

Project Link: [https://github.com/btafoya/createdockerwebserver](https://github.com/btafoya/createdockerwebserver)
