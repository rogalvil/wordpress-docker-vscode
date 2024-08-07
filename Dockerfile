# Use the official WordPress image as a base
FROM wordpress:php8.2-apache

# Install git
RUN apt-get update && apt-get install -y git

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
