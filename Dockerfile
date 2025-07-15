FROM php:8.1-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar el proyecto al contenedor
COPY . /var/www/html

# Copiar .env.example como .env
RUN cp /var/www/html/.env.example /var/www/html/.env

# Definir variables mínimas necesarias para que composer no falle
ENV APP_ENV=production
ENV APP_KEY=base64:placeholderkey12345678901234567890123456789012==
ENV APP_DEBUG=false

# Instalar dependencias PHP
RUN cd /var/www/html && composer install --no-dev --prefer-dist --optimize-autoloader

# Ajustar permisos
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Activar mod_rewrite
RUN a2enmod rewrite

# Cambiar DocumentRoot al directorio public/
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Exponer puerto 80
EXPOSE 80

# Comando de inicio
CMD ["apache2-foreground"]
