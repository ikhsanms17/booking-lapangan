# Menggunakan image resmi PHP 8.2 dengan Apache
FROM php:8.2-apache

# Install beberapa dependensi yang diperlukan
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip

# Mengaktifkan mod_rewrite Apache
RUN a2enmod rewrite

# Mengatur direktori kerja
WORKDIR /var/www/app

# Menambah User Student
RUN adduser student

# Menyalin file composer.json dan composer.lock ke dalam image
COPY composer.json composer.lock ./

# Menginstal dependensi PHP menggunakan Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-autoloader --no-scripts --no-progress --prefer-dist

# Menyalin kode aplikasi ke dalam image
COPY . .

# Menyalin file .env
RUN cp .env.example .env

# Mendefinisikan User
USER='student'

# Permission File dan Folder Laravel
RUN chown -R $USER:$USER ../app
RUN chgrp www-data ../app
RUN chgrp -R www-data bootstrap/ storage/
RUN chmod -R 775 storage

# Memuat ulang dependensi PHP dengan autoloader yang dihasilkan oleh Composer
RUN composer dump-autoload --optimize

# Generate Key Laravel
RUN php artisan key:generate

# Expose port jika aplikasi memerlukan
# EXPOSE 80

# Perintah untuk menjalankan Apache
CMD ["apache2-foreground"]

# DOCUMENTS
# simpan dockerfile didalam folder aplikasi
# jika dalam folder terdapat .env maka comment pada dockerfile untuk copy .env
# jalankan docker build image catalog-app
# docker build -t catalog-app .
# jalankan docker run pada port 81 dengan nama backend dari image catalog-app
# docker run -d -p 81:80 --name backend catalog-app
