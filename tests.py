from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.urls import reverse
from django.contrib.auth.hashers import make_password
import json
from .models import Docteur, Client, RendezVous, Notification, Disponibilite
from datetime import date, time

class ViewTests(APITestCase):
    def setUp(self):
        self.client = APIClient()
        
        # Créer un docteur pour les tests
        self.doctor = Docteur.objects.create(
            nom="Doctor",
            prenom="Test",
            email="doctor@test.com",
            password=make_password("testpass123"),
            genre="Homme",
            date_naissance=date(1980, 1, 1),
            telephone="12345678",
            localisation="Tunis",
            specialite="Cardiologue"
        )
        
        # Créer un client pour les tests
        self.client_user = Client.objects.create(
            nom="Client",
            prenom="Test",
            email="client@test.com",
            password=make_password("testpass123"),
            genre="Femme",
            date_naissance=date(1990, 1, 1),
            telephone="87654321"
        )
        
        # Créer une disponibilité pour le docteur
        self.disponibilite = Disponibilite.objects.create(
            docteur=self.doctor,
            debut_lundi=time(8, 0),
            fin_lundi=time(12, 0)
        )
        
        # Créer un rendez-vous pour les tests
        self.rdv = RendezVous.objects.create(
            docteur=self.doctor,
            client=self.client_user,
            nom="Patient",
            prenom="Test",
            genre="Homme",
            date_naissance=date(1995, 1, 1),
            telephone="55555555",
            date=date(2023, 12, 31),
            heure=time(10, 0)
        )
        
        # Créer une notification pour les tests
        self.notif = Notification.objects.create(
            doctor=self.doctor,
            message="Test notification",
            appointment_data={"patient": "Test Patient"}
        )

    # Tests d'inscription docteur
    def test_register_doctor_success(self):
        url = reverse('register_doctor')
        data = {
            "nom": "New",
            "prenom": "Doctor",
            "email": "new@doctor.com",
            "password": "newpass123",
            "genre": "Homme",
            "date_naissance": "1985-01-01",
            "telephone": "11111111",
            "localisation": "Sousse",
            "specialite": "Dermatologue"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
    def test_register_doctor_failure(self):
        url = reverse('register_doctor')
        data = {"email": "invalid"}  # Données incomplètes
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    # Tests d'inscription client
    def test_register_client_success(self):
        url = reverse('register_client')
        data = {
            "nom": "New",
            "prenom": "Client",
            "email": "new@client.com",
            "password": "newpass123",
            "genre": "Femme",
            "date_naissance": "1995-01-01",
            "telephone": "22222222"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    # Tests de connexion
    def test_login_doctor_success(self):
        url = reverse('login_doctor')
        data = {
            "email": "doctor@test.com",
            "password": "testpass123"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
    def test_login_doctor_invalid_credentials(self):
        url = reverse('login_doctor')
        data = {
            "email": "doctor@test.com",
            "password": "wrongpassword"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_client_success(self):
        url = reverse('login_client')
        data = {
            "email": "client@test.com",
            "password": "testpass123"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    # Tests de recherche
    def test_search_doctors(self):
        url = reverse('search_doctors')
        response = self.client.get(url, {'search': 'Cardiologue'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_search_doctors_by_city_speciality(self):
        url = reverse('search_doctors1')
        response = self.client.get(url, {'city': 'Tunis', 'specialite': 'Cardiologue'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    # Tests disponibilités
    def test_add_update_availability(self):
        url = reverse('ajout_disponibilites')
        data = {
            "docteur": self.doctor.id,
            "debut_lundi": "08:00:00",
            "fin_lundi": "12:00:00",
            "debut_mardi": "09:00:00",
            "fin_mardi": "13:00:00"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_get_availability(self):
        url = reverse('get_disponibilites', args=[self.doctor.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    # Tests rendez-vous
    def test_get_rendezvous(self):
        url = reverse('get_rendezvous')
        response = self.client.get(url, {'docteur_id': self.doctor.id})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
    def test_add_rendezvous(self):
        url = reverse('add_rendezvous')
        data = {
            "docteur": self.doctor.id,
            "client": self.client_user.id,
            "nom": "New",
            "prenom": "Patient",
            "genre": "Femme",
            "date_naissance": "1990-01-01",
            "telephone": "99999999",
            "date": "2023-12-25",
            "heure": "14:00:00"
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_get_client_appointments(self):
        # Utilisation du chemin direct car le nom de l'URL n'est pas défini
        url = f'/api/rendezvous/client/{self.client_user.id}/'
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)  # Vérifie qu'on a bien le rendez-vous créé

    def test_delete_appointment(self):
        new_rdv = RendezVous.objects.create(
            docteur=self.doctor,
            client=self.client_user,
            date=date(2023, 12, 25),
            heure=time(14, 0)
        )
        url = reverse('supprimer_rendezvous', args=[new_rdv.id])
        response = self.client.delete(url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    # Tests notifications
    def test_create_notification(self):
        url = reverse('create-notification')
        data = {
            "doctor": self.doctor.id,
            "message": "Nouveau rendez-vous",
            "appointment_data": {
                "patient": "Test Patient",
                "date": "2023-12-31"
            }
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_get_doctor_notifications(self):
        url = reverse('doctor_notifications', args=[self.doctor.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_unread_notifications_count(self):
        url = reverse('unread-notifications-count', args=[self.doctor.id])
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_mark_notification_as_read(self):
        url = reverse('mark-notification-read', args=[self.notif.id])
        response = self.client.patch(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.notif.refresh_from_db()
        self.assertTrue(self.notif.is_read)