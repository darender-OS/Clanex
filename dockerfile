# Use official PHP 8.1 with Apache image
FROM php:8.1-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring intl zip xml

# Enable Apache mod_rewrite for pretty URLs
RUN a2enmod rewrite

# Install Composer (copy from official composer image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy all project files to the container
COPY . /var/www/html/

# Install PHP dependencies without dev packages and optimize autoloader
RUN composer install --no-dev --optimize-autoloader

# Set proper permissions (adjust paths as needed)
RUN chown -R www-data:www-data /var/www/html/protected/runtime /var/www/html/uploads

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
