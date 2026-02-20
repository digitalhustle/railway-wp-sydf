# ============================================================
# Dockerfile for shareyourdreamfriday.com on Railway
# Based on the official WordPress image with Apache MPM event
# fix for better performance on containerized environments.
# ============================================================

FROM wordpress:latest

# Switch Apache from mpm_prefork to mpm_event for better
# performance and compatibility with Railway's container model.
RUN a2dismod mpm_prefork && \
    a2enmod mpm_event && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod expires

# Install additional PHP extensions useful for WordPress
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom PHP configuration for better performance
COPY wordpress-config/php.ini /usr/local/etc/php/conf.d/wordpress-custom.ini

# Copy custom Apache configuration
COPY wordpress-config/apache.conf /etc/apache2/conf-available/wordpress-custom.conf
RUN a2enconf wordpress-custom

# Ensure the uploads directory exists and has correct permissions
RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads && \
    chmod 755 /var/www/html/wp-content/uploads

# Expose port 80
EXPOSE 80
