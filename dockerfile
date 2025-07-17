# Use official PHP 8.2 FPM image as base
FROM php:8.2-fpm

# Install system dependencies for PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libldap2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl pdo_mysql zip opcache exif ldap gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy composer files first to leverage docker cache
COPY composer.json composer.lock ./

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Install PHP dependencies without dev packages and optimize autoloader
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy the rest of your application source code
COPY . .

# Fix permissions so www-data user can write to storage and config directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/config /var/www/html/assets || true

# Expose port 9000 for php-fpm
EXPOSE 9000

# Run php-fpm server
CMD ["php-fpm"]
