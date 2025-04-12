from venv import logger
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Docteur,Notification
from .serializers import DocteurSerializer
from django.contrib.auth import authenticate
from django.http import JsonResponse
from .models import  Client
from rest_framework.authtoken.models import Token
from .serializers import ClientSerializer
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import check_password
from django.db.models import Q



from django.http import JsonResponse
from django.contrib.auth.hashers import check_password
from django.views.decorators.csrf import csrf_exempt
import json

from .models import Disponibilite, Docteur, Client, RendezVous
from .serializers import DisponibiliteSerializer, DocteurSerializer, ClientSerializer, RendezVousSerializer,NotificationSerializer



@api_view(['POST'])
def register_doctor(request):
    serializer = DocteurSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "Docteur enregistré avec succès !"}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def register_client(request):
    serializer = ClientSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "Inscription réussie"}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def get_doctors(request):
    doctors = Docteur.objects.all()
    serializer = DocteurSerializer(doctors, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)
 
@api_view(['GET'])
def get_client(request):
    clients = Client.objects.all()
    serializer = ClientSerializer(clients, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@csrf_exempt
def login_doctor(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
        except Exception as e:
            return JsonResponse({'error': 'JSON invalide'}, status=400)

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return JsonResponse({'error': 'Email et mot de passe sont requis'}, status=400)

        try:
            doctor = Docteur.objects.get(email=email)
        except Docteur.DoesNotExist:
            return JsonResponse({'error': 'Identifiants invalides'}, status=400)

        if check_password(password, doctor.password):
            # Si tu souhaites renvoyer un token, tu peux intégrer django-rest-framework-authtoken.
            # Pour l'instant, nous renvoyons simplement un message de succès et l'identifiant du docteur.
            return JsonResponse({'message': 'Connexion réussie', 'doctor_id': doctor.id}, status=200)
        else:
            return JsonResponse({'error': 'Identifiants invalides'}, status=400)
    else:
        return JsonResponse({'error': 'Méthode non autorisée'}, status=405)


@csrf_exempt
def login_client(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
        except Exception as e:
            return JsonResponse({'error': 'JSON invalide'}, status=400)

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return JsonResponse({'error': 'Email et mot de passe sont requis'}, status=400)

        try:
            client = Client.objects.get(email=email)
        except Client.DoesNotExist:
            return JsonResponse({'error': 'Identifiants invalides'}, status=400)

        if check_password(password, client.password):
            # Si tu souhaites renvoyer un token, tu peux intégrer django-rest-framework-authtoken.
            # Pour l'instant, nous renvoyons simplement un message de succès et l'identifiant du docteur.
            return JsonResponse({'message': 'Connexion réussie', 'client_id': client.id}, status=200)
        else:
            return JsonResponse({'error': 'Identifiants invalides'}, status=400)
    else:
        return JsonResponse({'error': 'Méthode non autorisée'}, status=405)
    

@api_view(['GET'])
def search_doctors(request):
    search_term = request.query_params.get('search', '')

    if not search_term:
        return Response({"error": "Le paramètre 'search' est requis."}, status=status.HTTP_400_BAD_REQUEST)

    # Recherche dans les champs nom, spécialité et localisation
    doctors = Docteur.objects.filter(
        Q(nom__icontains=search_term) | 
        Q(specialite__icontains=search_term) | 
        Q(localisation__icontains=search_term)
    )

    serializer = DocteurSerializer(doctors, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['GET'])
def search_doctors1(request):
    
    city = request.query_params.get('city', '')
    specialite = request.query_params.get('specialite', '')

    # Filtrage des médecins par ville et spécialité
    doctors = Docteur.objects.filter(
        specialite__icontains=specialite,  # Filtre par spécialité
        localisation__icontains=city       # Filtre par ville
    )

    serializer = DocteurSerializer(doctors, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['POST'])
def ajout_disponibilites(request):
    try:
        docteur_id = request.data.get("docteur")
        if not docteur_id:
            return Response({"error": "docteur_id est requis"}, status=status.HTTP_400_BAD_REQUEST)

        disponibilites_data = {
            key: request.data.get(key) for key in [
                "debut_lundi", "fin_lundi", "debut_mardi", "fin_mardi",
                "debut_mercredi", "fin_mercredi", "debut_jeudi", "fin_jeudi",
                "debut_vendredi", "fin_vendredi", "debut_samedi", "fin_samedi",
                "debut_dimanche", "fin_dimanche"
            ]
        }

        disponibilite, created = Disponibilite.objects.update_or_create(
            docteur_id=docteur_id,
            defaults=disponibilites_data,
        )

        return Response({"message": "Disponibilités mises à jour"}, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
def get_disponibilites(request, id):
    try:
        disponibilite = Disponibilite.objects.get(docteur_id=id)
        serializer = DisponibiliteSerializer(disponibilite)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Disponibilite.DoesNotExist:
        return Response({"error": "Disponibilité non trouvée"}, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET', 'PUT'])
def get_update_disponibilites(request, doctor_id):
    try:
        disponibilite = Disponibilite.objects.get(docteur_id=doctor_id)

        if request.method == 'PUT':
            serializer = DisponibiliteSerializer(disponibilite, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({"message": "Disponibilités mises à jour avec succès"}, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        serializer = DisponibiliteSerializer(disponibilite)
        return Response(serializer.data, status=status.HTTP_200_OK)

    except Disponibilite.DoesNotExist:
        return Response({"error": "Disponibilité non trouvée"}, status=status.HTTP_404_NOT_FOUND)
    
    
@api_view(['GET'])
def get_rendezvous(request):
    docteur_id = request.GET.get('docteur_id')
    patient_id = request.GET.get('patient_id')

    # Filtrage optionnel par docteur et patient
    queryset = RendezVous.objects.all()
    if docteur_id:
        queryset = queryset.filter(docteur_id=docteur_id)
    if patient_id:
        queryset = queryset.filter(patient_id=patient_id)

    serializer = RendezVousSerializer(queryset, many=True)
    
    return Response({'rendezvous': serializer.data}, status=status.HTTP_200_OK)

@api_view(['POST'])
def add_rendezvous(request):
    if request.method == 'POST':
        serializer = RendezVousSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(
                {'message': 'Rendez-vous ajouté avec succès !', 'rendezvous': serializer.data}, 
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
@api_view(['GET'])
def get_doctor_by_id(request, id):
    print(f"🔍 Requête API reçue pour le médecin ID: {id}")

    try:
        doctor = Docteur.objects.get(id=id)
        serializer = DocteurSerializer(doctor)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Docteur.DoesNotExist:
        print(f"❌ Erreur: Aucun médecin trouvé avec l'ID {id}")
        return Response({"error": "Médecin non trouvé"}, status=status.HTTP_404_NOT_FOUND)
    

@api_view(['GET'])
def get_rendezvous_medecin(request, doctor_id):
    try:
        rendezvous = RendezVous.objects.filter(docteur_id=doctor_id)
        data = [
            {
                "id": r.id,
                "date": r.date.strftime("%Y-%m-%d"),
                "heure": r.heure.strftime("%H:%M"),  # Enlever les secondes
                "nom": r.nom if r.nom else "Inconnu",
                "prenom": r.prenom if r.prenom else "Inconnu",
                "statut": r.statut
            }
            for r in rendezvous
        ]

        return JsonResponse(data, safe=False)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
    

    
@api_view(['GET'])
def get_client_by_id(request, id):
    try:
        client = Client.objects.get(id=id)
        serializer = ClientSerializer(client)
        return Response(serializer.data)
    except Client.DoesNotExist:
        return Response({"error": "Client non trouvé"}, status=404)
    


@api_view(['GET'])
def rendezvous_client(request, client_id):
    rendezvous = RendezVous.objects.filter(client_id=client_id).select_related('docteur')
    serializer = RendezVousSerializer(rendezvous, many=True)
    return Response(serializer.data)


@api_view(['DELETE'])
def supprimer_rendezvous(request, pk):
    try:
        rendezvous = RendezVous.objects.get(pk=pk)
        rendezvous.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except RendezVous.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
    

# views.py
@api_view(['POST'])
def create_notification(request):
    try:
        # Convertir appointment_data si envoyé en tant que string JSON
        data = request.data.copy()
        if isinstance(data.get('appointment_data'), str):
            data['appointment_data'] = json.loads(data['appointment_data'])
            
        # Valider que les champs requis sont présents
        required_fields = ['doctor', 'message', 'appointment_data']
        if not all(field in data for field in required_fields):
            return Response(
                {"error": "Champs manquants: doctor, message ou appointment_data"},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        # Enregistrement en base
        notification = Notification.objects.create(
            doctor_id=data['doctor'],
            message=data['message'],
            appointment_data=json.dumps(data['appointment_data']),
            is_read=False
        )
        
        return Response(
            {"id": notification.id, "status": "created"},
            status=status.HTTP_201_CREATED
        )
        
    except Exception as e:
        return Response(
            {"error": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    

# views.py
# views.py
@api_view(['GET'])
def doctor_notifications(request, doctor_id):
    print(f"Doctor ID reçu : {doctor_id}")  # Debugging
    notifications = Notification.objects.filter(doctor_id=doctor_id).order_by('-created_at')
    
    data = []
    for notif in notifications:
        try:
            appointment_data = json.loads(notif.appointment_data)
        except:
            appointment_data = {}
            
        data.append({
            'id': notif.id,
            'message': notif.message,
            'appointment_data': appointment_data,
            'is_read': notif.is_read,
            'created_at': notif.created_at,
            'doctor': notif.doctor_id
        })
    
    return Response(data)

@api_view(['GET'])
def unread_notifications_count(request, doctor_id):
    count = Notification.objects.filter(doctor_id=doctor_id, is_read=False).count()
    return Response({'count': count})

@api_view(['PATCH'])
def mark_as_read(request, notification_id):
    try:
        notification = get_object_or_404(Notification, pk=notification_id)
        if not notification.is_read:
            notification.is_read = True
            notification.save()
            return Response({'status': 'marked as read'}, status=200)
        return Response({'status': 'already read'}, status=200)
    except Exception as e:
        return Response({'error': str(e)}, status=400)
