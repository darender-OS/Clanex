FROM php:8.1-apache

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
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip mbstring exif xml ldap intl \
    && a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

RUN chown -R www-data:www-data /var/www/html/assets /var/www/html/protected/runtime /var/www/html/protected/modules
RUN chmod -R 755 /var/www/html/assets /var/www/html/protected/runtime /var/www/html/protected/modules

EXPOSE 80

CMD ["apache2-foreground"]
