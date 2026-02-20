# ============================================================
# Dockerfile for shareyourdreamfriday.com on Railway
# Based on the official WordPress image (Apache).
#
# FIXES APPLIED (v3 - FINAL):
#   Removed ALL Apache MPM switching code entirely.
#
#   Root cause analysis: The official wordpress:latest image is
#   built on php:8.3-apache, which ships with mpm_prefork enabled
#   via TWO symlinks in /etc/apache2/mods-enabled/:
#     - mpm_prefork.load
#     - mpm_prefork.conf
#   Our a2dismod command removed the .load symlink at build time,
#   but the .conf symlink remained. At runtime, Apache found both
#   mpm_prefork.conf (from the residual symlink) and mpm_event.load
#   (which we added), causing the fatal "More than one MPM loaded"
#   error. The a2enmod/a2dismod approach is unreliable across
#   different base image versions.
#
#   The correct fix is to NOT switch MPMs at all. The default
#   mpm_prefork is perfectly suitable for a WordPress blog and is
#   what the official Railway WordPress templates use.
# ============================================================

FROM wordpress:latest

# Enable Apache modules needed for WordPress (rewrite, headers, expires).
# These are safe to enable and do not conflict with any MPM.
RUN a2enmod rewrite headers expires 2>/dev/null || true

# Copy custom PHP configuration for better performance & security
COPY wordpress-config/php.ini /usr/local/etc/php/conf.d/wordpress-custom.ini

# Copy custom Apache security & caching configuration
COPY wordpress-config/apache.conf /etc/apache2/conf-available/wordpress-custom.conf
RUN a2enconf wordpress-custom

# Ensure the uploads directory exists with correct permissions.
RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads && \
    chmod 755 /var/www/html/wp-content/uploads

EXPOSE 80
