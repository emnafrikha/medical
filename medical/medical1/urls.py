from django.urls import path
from .views import register_doctor
from .views import login_doctor, login_client
from .views import get_doctors, get_client
from .views import register_client
from .views import search_doctors
from .views import search_doctors1
from .views import get_rendezvous_medecin

from .views import  add_rendezvous, ajout_disponibilites, get_rendezvous, register_doctor
from .views import login_doctor, login_client,supprimer_rendezvous,doctor_notifications,unread_notifications_count,mark_as_read
from .views import get_doctors, get_client ,get_client_by_id,create_notification
from .views import register_client, get_disponibilites, get_update_disponibilites, get_doctor_by_id ,rendezvous_client
urlpatterns = [
     path('register/', register_doctor, name='register_doctor'),
     path('doctors/', get_doctors, name='get_doctors'), 
     path('login/', login_doctor, name='login_doctor'),
     path('loginClient/', login_client, name='login_client'),
     path('register_client/', register_client, name='register_client'),
     path('clients/', get_client, name='get_client'), 
	path('search-doctors/', search_doctors, name='search_doctors'), 
	path('search-doctors1/', search_doctors1, name='search_doctors1'),  # Nouvelle route
	path("disponibilites/<int:id>/", get_disponibilites, name="get_disponibilites"),  # GET pour récupérer
     path("disponibilites/<int:doctor_id>/update/", get_update_disponibilites, name="get_update_disponibilites"),  # PUT pour mettre à 
	path('disponibilites/add/', ajout_disponibilites, name='ajout_disponibilites'),
     path('rendezvous/', get_rendezvous, name='get_rendezvous'),
     path('rendezvous/add/', add_rendezvous, name='add_rendezvous'),
	path('doctor/<int:id>/', get_doctor_by_id, name='get_doctor_by_id'),
	path('rendezvous/medecin/<int:doctor_id>/', get_rendezvous_medecin, name='get_rendezvous_medecin'),
     path('client/<int:id>/', get_client_by_id, name='get_client_by_id'),
	path('rendezvous/client/<int:client_id>/', rendezvous_client),
    	path('rendezvous/<int:pk>/supprimer/', supprimer_rendezvous, name='supprimer_rendezvous'),
	path('notification/', create_notification, name='create-notification'),
	path('doctors/<int:doctor_id>/notifications/', doctor_notifications, name='doctor_notifications'),
     path('doctors/<int:doctor_id>/notifications/unread-count/', unread_notifications_count, name='unread-notifications-count'),
     path('notifications/<int:notification_id>/mark-as-read/', mark_as_read,  name='mark-notification-read'),
]





