from rest_framework import serializers
from .models import Docteur, Client,Disponibilite,RendezVous,Notification



class DocteurSerializer(serializers.ModelSerializer):
    class Meta:
        model = Docteur
        fields = '__all__'
        extra_kwargs = {
            'localisation': {'required': False},
            'specialite': {'required': False},
        }

class ClientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Client
        fields = '__all__'

class DisponibiliteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Disponibilite
        fields = '__all__'


class RendezVousSerializer(serializers.ModelSerializer):
    docteur_nom = serializers.CharField(source='docteur.nom', read_only=True)
    docteur_specialite = serializers.CharField(source='docteur.specialite', read_only=True)
    
    class Meta:
        model = RendezVous
        fields = [
            'id', 'nom', 'prenom', 'genre', 'date_naissance', 'telephone',
            'description_maladie', 'date', 'heure', 'statut',
            'docteur', 'docteur_nom', 'docteur_specialite', 'client'
        ]



# serializers.py
class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
