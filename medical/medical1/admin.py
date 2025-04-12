from django.contrib import admin
from .models import Disponibilite, Docteur, Client, RendezVous,Notification

admin.site.register(Docteur)
admin.site.register(Client)
admin.site.register(Disponibilite)
admin.site.register(RendezVous)
admin.site.register(Notification)