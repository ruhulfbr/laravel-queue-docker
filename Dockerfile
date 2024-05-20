FROM php:8.3-apache

RUN apt-get update && \
    apt-get install -y git zip unzip libpng-dev libonig-dev libxml2-dev curl

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache modules and configure virtual host
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.json and composer.lock to container
COPY composer.json composer.lock /var/www/html/

WORKDIR /var/www/html

# Install PHP dependencies
RUN export COMPOSER_ALLOW_SUPERUSER=1 && composer install --no-scripts

# Copy wait-for-it.sh
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

# Copy apache-config file
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80 (Apache)
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
