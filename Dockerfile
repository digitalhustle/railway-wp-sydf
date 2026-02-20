# ============================================================
# Dockerfile for shareyourdreamfriday.com on Railway
# Based on the official WordPress image (Apache).
#
# FIXES APPLIED (v2):
#   1. Removed manual GD extension install — the official
#      wordpress:latest image already includes GD. Reinstalling
#      it caused the "gd is already loaded!" warning and added
#      ~2 minutes of unnecessary build time.
#
#   2. Fixed Apache MPM conflict ("More than one MPM loaded").
#      The official wordpress image ships with mpm_prefork
#      already enabled. Simply running `a2enmod mpm_event`
#      without first disabling ALL mpm modules caused Apache
#      to load two MPM modules simultaneously, which is fatal.
#      The fix is to explicitly disable mpm_prefork AND
#      mpm_worker before enabling mpm_event.
# ============================================================

FROM wordpress:latest

# --- Fix Apache MPM conflict ---
# Disable ALL MPM modules first, then enable only mpm_event.
# This prevents the "More than one MPM loaded" fatal error.
RUN a2dismod mpm_prefork mpm_worker mpm_event 2>/dev/null || true && \
    a2enmod mpm_event && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod expires

# Copy custom PHP configuration for better performance & security
COPY wordpress-config/php.ini /usr/local/etc/php/conf.d/wordpress-custom.ini

# Copy custom Apache security & caching configuration
COPY wordpress-config/apache.conf /etc/apache2/conf-available/wordpress-custom.conf
RUN a2enconf wordpress-custom

# Ensure the uploads directory exists with correct permissions.
# The persistent volume will be mounted here at runtime.
RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads && \
    chmod 755 /var/www/html/wp-content/uploads

# Expose port 80 (Railway handles SSL termination externally)
EXPOSE 80
