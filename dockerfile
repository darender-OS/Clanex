FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libicu-dev libonig-dev libxml2-dev \
 && docker-php-ext-install pdo_mysql mbstring intl zip xml

RUN a2enmod rewrite

RUN chown -R www-data:www-data /var/www/html/assets
RUN chmod -R 755 /var/www/html/assets

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libldap2-dev \
    libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd exif ldap zip pdo_mysql xml \
    && pecl install apcu \
    && docker-php-ext-enable apcu

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock /var/www/html/

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html/protected/runtime /var/www/html/uploads

EXPOSE 80

CMD ["apache2-foreground"]
