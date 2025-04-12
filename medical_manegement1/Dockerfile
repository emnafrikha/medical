# Dockerfile personnalisé pour Flutter
FROM cirrusci/flutter:3.29.2  # version compatible avec flutter_lints 5.0.0

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    libglu1-mesa \
 && apt-get clean

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers du projet Flutter
COPY medical_manegement1/ ./

# Précharger les dépendances
RUN flutter pub get

# Commande par défaut : build web en release
CMD ["flutter", "build", "web", "--release"]
