# WordPress Development Environment with Docker and DevContainer

This project provides a development environment for WordPress using Docker and
Visual Studio Code's DevContainer. It includes WordPress, MySQL, and phpMyAdmin
configured to run in Docker containers.

## Requirements

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Remote - Containers Extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Project Structure

```
.
├── .devcontainer.json
├── website
│   └── (your WordPress installation)
├── data
│   └── (MySQL database data)
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Setup

1. **Clone the repository:**

  ```sh
  git clone https://github.com/your-username/your-repository.git
  cd your-repository
  ```

2. **Create the necessary directories:**
  ```sh
  mkdir website data
  ```

3. **Create Dockerfile:**
  Create a file named Dockerfile at the root of the project with the following content:

  ```dockerfile
  FROM wordpress:php8.2-apache

  # Install git
  RUN apt-get update && apt-get install -y git

  # Install WP-CLI
  RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
      && chmod +x wp-cli.phar \
      && mv wp-cli.phar /usr/local/bin/wp
  ```

4. **Configure DevContainer:**
  Create a file named .devcontainer.json with the following content:

  ```json
  {
    "name": "WordPress Dev Container",
    "dockerComposeFile": "docker-compose.yml",
    "service": "wordpress",
    "workspaceFolder": "/var/www/html",
    "settings": {
      "terminal.integrated.shell.linux": "/bin/bash"
    },
    "extensions": [
      "ms-azuretools.vscode-docker",
      "esbenp.prettier-vscode",
      "dbaeumer.vscode-eslint"
    ],
    "postCreateCommand": "chown -R www-data:www-data /var/www/html"
  }
  ```

5. **Configure Docker Compose:**
  Create a file named docker-compose.yml at the root of the project with the
  following content:

  ```yaml
  version: '3.1'

  services:
    wordpress:
      build:
        context: .
        dockerfile: Dockerfile
      ports:
        - "8000:80"
      environment:
        WORDPRESS_DB_HOST: mysql
        WORDPRESS_DB_USER: root
        WORDPRESS_DB_PASSWORD: root
        WORDPRESS_DB_NAME: wordpress_db
      volumes:
        - ./website:/var/www/html

    mysql:
      image: mysql:5.7
      environment:
        MYSQL_DATABASE: wordpress_db
        MYSQL_ROOT_PASSWORD: root
      ports:
        - "3306:3306"
      volumes:
        - ./data:/var/lib/mysql

    phpmyadmin:
      image: phpmyadmin/phpmyadmin
      links:
        - mysql
      ports:
        - "8081:80"
      environment:
        PMA_HOST: mysql
        MYSQL_ROOT_PASSWORD: root

  volumes:
    website:
    data:
  ```

## Usage

1. **Open the project in DevContainer:**

  - Open Visual Studio Code.
  - Navigate to the project folder.
  - Click on the Remote Explorer icon in the left sidebar.
  - Select "Open Folder in Container..." and choose your project folder.

2. **Start the containers:**
  In the VSCode terminal, run the following command to start the containers:

  ```sh
  docker compose up -d
  ```

3. **Access WordPress and phpMyAdmin:**

  - WordPress: [http://localhost:8000](http://localhost:8000)
  - phpMyAdmin: [http://localhost:8081](http://localhost:8081)

4. **Restore the database:**

  - Open phpMyAdmin at [http://localhost:8081](http://localhost:8081).
  - Log in with the user `root` and password `root`.
  - Select the database `wordpress_db`.
  - Go to the "Import" tab, select your SQL backup file, and click "Go" to import the data.

5. **Update links and options:**

  - Access the WordPress container:

    ```sh
    docker exec -it [wordpress_container_name] /bin/bash
    ```

    Replace `[wordpress_container_name]` with the actual name or ID of the WordPress container.

  - Navigate to the WordPress installation directory:

    ```sh
    cd /var/www/html
    ```

  - Use the `wp search-replace` command to update the links:

    ```sh
    wp search-replace 'http://old-domain.com' 'http://new-domain.com' --skip-columns=guid --allow-root
    ```

    Replace `http://old-domain.com` and `http://new-domain.com` with your old and new domain names, respectively.

  - Exit the container:

    ```sh
    exit
    ```

6. **Fix file permissions:**

  If you encounter permission issues, access the WordPress container again and adjust the permissions:

  ```sh
  docker exec -it [wordpress_container_name] /bin/bash
  chown -R www-data:www-data /var/www/html
  ```

7. **Stop the containers:**

  To stop the containers, run the following command:

  ```sh
  docker compose down
  ```

## Benefits

- **Isolation:** Docker containers provide isolation, ensuring that the WordPress application and the database have their own environments without conflicts with other applications on the host system.
- **Portability:** Dockerized applications are highly portable. You can run your WordPress site on any system that supports Docker without worrying about differences in underlying infrastructure.
- **Easy Deployment and Scaling:** Docker simplifies the deployment process. You can deploy your WordPress application and database containers with a single command. Scaling becomes more manageable by replicating containers horizontally to handle increased traffic or load.
- **Version Control:** Docker allows you to version control your application environments. By defining the environment in code (Dockerfile and docker-compose.yml), you can track changes over time and reproduce the same environment across different stages of development or on different machines.
- **Environment Variables and Configurations:** Docker Compose enables you to set environment variables for configurations, such as database connection details, WordPress salts, etc. This allows for flexible and secure configuration management.

## Based on
https://medium.com/@samsaydali/dockerize-a-wordpress-website-phpmyadmin-and-its-database-51bab71666a9
