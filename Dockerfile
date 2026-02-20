FROM wordpress:latest

RUN mkdir -p /var/www/html/wp-content/uploads && \
    chown -R www-data:www-data /var/www/html/wp-content/uploads && \
    chmod 755 /var/www/html/wp-content/uploads

EXPOSE 80
