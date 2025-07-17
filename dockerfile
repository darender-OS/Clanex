# Use official PHP Apache image with PHP 8.1 (adjust version if needed)
FROM php:8.1-apache

# Install required PHP extensions for HumHub
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libzip-dev \
    zip \
    unzip \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip opcache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy HumHub source into container
COPY . /var/www/html

# Set permissions (adjust user/group as needed)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Run Apache in foreground
CMD ["apache2-foreground"]
