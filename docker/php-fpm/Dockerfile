FROM php:fpm-alpine
WORKDIR /var/www
RUN apk update && apk add --no-cache \
        postgresql-dev \
    && docker-php-ext-install -j$(nproc) pgsql \
    && docker-php-ext-install -j$(nproc) pdo_pgsql
RUN mkdir /var/www/symfony
RUN chown -R www-data:www-data /var/www
CMD ["php-fpm"]
EXPOSE 9000
