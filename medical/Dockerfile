# Utilise l'image officielle de Python
FROM python:3.10-slim

# Défini le répertoire de travail
WORKDIR /app

# Copie le code du backend dans le conteneur
COPY medical/ /app/

# Installe les dépendances
RUN pip install -r requirements.txt

# Expose le port 8000
EXPOSE 8000

# Démarre le serveur Django
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
