FROM php:8.2-fpm

# Install system dependencies and PHP extensions (including intl)
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl pdo_mysql zip opcache

# Set working directory
WORKDIR /var/www/html

# Copy composer.json and composer.lock first for better caching
COPY composer.json composer.lock ./

# Install composer dependencies without dev packages and optimize autoloader
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && composer install --no-dev --optimize-autoloader --no-interaction

# Copy all application source code
COPY . .

# Fix permissions recursively for www-data user on entire app directory
RUN chown -R www-data:www-data /var/www/html

# Expose port 9000 for PHP-FPM (or 80 if you have nginx/apache in front)
EXPOSE 9000

CMD ["php-fpm"]
