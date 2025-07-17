FROM php:8.2-apache

# Install system dependencies and PHP extensions required by your project
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libldap2-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    zip unzip git \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) intl xml zip pdo_mysql exif ldap gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy composer binary from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy only composer files and install dependencies first for better caching
COPY composer.json composer.lock ./

# Run composer install with proper environment variable to allow root usage (in container)
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction

# Copy all application files
COPY . .

# Fix permissions so PHP (www-data) can write config and assets
RUN chown -R www-data:www-data /var/www/html/config /var/www/html/assets

# Expose port 80
EXPOSE 80

# Start apache in foreground
CMD ["apache2-foreground"]
