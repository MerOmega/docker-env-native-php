# Base image to use Composer
FROM composer:2.7.6 AS composer_base

# Base image to use PHP 8.3.7 FPM
FROM php:8.3.7-fpm

# Copy Composer from the base image
COPY --from=composer_base /usr/bin/composer /usr/bin/composer

# Install necessary packages and PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    zip \
    unzip \
    git \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    libpq-dev \
    libzip-dev \
    bash \
    vim \
    bash-completion \
    zsh \
    autoconf \
    g++ \
    make \
    && docker-php-ext-install intl pdo_mysql pdo pdo_pgsql mbstring exif pcntl bcmath gd zip sockets \
    && rm -rf /var/lib/apt/lists/*

## Install packages for Electron
RUN apt-get update && apt-get install -y \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libgbm1 \
    libpango-1.0-0 \
    libwayland-client0 \
    libwayland-egl1 \
    libwayland-server0 \
    libxkbcommon0 \
    libfreetype6 \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    wine64 \
    wine32 \
    winbind \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get purge -y --auto-remove \
    g++ \ 
    make \
    autoconf

# Install and configure Xdebug
RUN apt-get update && apt-get install -y \
    $PHPIZE_DEPS \
    && pecl install xdebug-3.3.2 \
    && docker-php-ext-enable xdebug \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    dbus \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*
    
# Clean up APT when done.
RUN apt clean && rm -rf /var/lib/apt/lists/*

ARG XDEBUG_DIR

# Copy Xdebug configuration
COPY $XDEBUG_DIR "${PHP_INI_DIR}/conf.d/xdebug.ini"

# Argument for the UID and GID of the host user
ARG UID=1000
ARG GID=1000
ARG CONTAINER_USER
ARG CONTAINER_GROUP

# Create a user with the same UID and GID as the host user
RUN groupadd -g $GID $CONTAINER_USER \
    && useradd -u $UID -g $CONTAINER_GROUP -m $CONTAINER_USER

# Set the working directory
WORKDIR /var/www/html

# Change ownership of the working directory
RUN chown -R $CONTAINER_USER:$CONTAINER_GROUP /var/www/html

# Switch to the new user
USER $CONTAINER_USER

# Install Oh My Zsh for root user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Set the gnzh theme for root
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="gnzh"/' ~/.zshrc

# Install Zsh plugins and adjust .zshrc for root
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Create the .zsh_history file with proper permissions for root
RUN touch ~/.zsh_history \
    && chmod 644 ~/.zsh_history

# Expose port 9000
EXPOSE 9000

# Command to start PHP-FPM
CMD ["php-fpm"]
