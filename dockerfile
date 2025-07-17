FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libicu-dev libonig-dev libxml2-dev \
 && docker-php-ext-install pdo_mysql mbstring intl zip xml

RUN a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock /var/www/html/

RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html/protected/runtime /var/www/html/uploads

EXPOSE 80

CMD ["apache2-foreground"]
