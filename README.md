# Create Docker Web Server

This repository contains a script to set up a web application environment on a Ubuntu base, with Apache, MySQL, PHP (5.6 7.1 7.2 7.3 7.4 8.0 8.1 8.2 8.3), PHP extensions, Redis, Gearman Job Server, and Supervisor.

<a href="https://www.buymeacoffee.com/luckyedward"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me Drink&emoji=🍹&slug=luckyedward&button_colour=5F7FFF&font_colour=ffffff&font_family=Bree&outline_colour=000000&coffee_colour=FFDD00" style="float: right;" /></a>

## Features

- **Dockerized Environment**: Run your web server in a containerized environment.
- **PHP Extensions**: Easily configure and install PHP extensions.
- **MySQL Database**: Set up a MySQL database with customizable credentials.
- **Supervisor**: Manage background processes with Supervisor.
- **Interactive Setup**: Optionally configure the setup interactively.

## Prerequisites

- Linuxr Host
- Docker & Docker Compose
- Git

## Directory Structure
The script creates the following directory structure:

```text
config/
├── apache2/
│   └── 000-default.conf
├── php.ini
├── my.cnf
├── supervisord.conf
├── init.sql (if SQL file is provided)
web_root/
├── index.php
mysql_data/
Dockerfile
docker-compose.yml
.env
```

## Commands

- **Build the Docker image**:

    ```bash
    docker compose build
    ```

    Follow the interactive prompts to configure the environment. The script will generate the necessary configuration files, build the Docker image, and run the container.
- **Build and Insert data into newly created MySQL Database**

    ```bash
    ./createdockerwebserver.sh path/to/your/sqlfile.sql
    ```
    Follow the interactive prompts to configure the environment. The script will generate the necessary configuration files, build the Docker image, and run the container.

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
