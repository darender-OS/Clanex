FROM php:8.1-apache

# Install system dependencies and PHP extensions needed by HumHub
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libldap2-dev \
    unzip \
    zip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip mbstring exif xml ldap \
    && a2enmod rewrite

# Copy composer binary from official composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer.json and composer.lock for dependency install
COPY composer.json composer.lock ./

# Install PHP dependencies without dev packages and optimize autoloader
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy all source files
COPY . .

# Fix permissions so Apache/PHP can write to assets folder
RUN chown -R www-data:www-data /var/www/html/assets /var/www/html/protected/runtime /var/www/html/protected/modules
RUN chmod -R 755 /var/www/html/assets /var/www/html/protected/runtime /var/www/html/protected/modules

EXPOSE 80

CMD ["apache2-foreground"]
