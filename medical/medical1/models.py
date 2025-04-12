from django.db import models

from django.contrib.auth.hashers import make_password

GENRE_CHOICES = [
        ('Homme', 'Homme'),
        ('Femme', 'Femme'),
    ]
class Docteur(models.Model):
    

    SPECIALITE_CHOICES = [
        ('Généraliste', 'Généraliste'),
        ('Cardiologue', 'Cardiologue'),
        ('Dermatologue', 'Dermatologue'),
        ('Pédiatre', 'Pédiatre'),
        ('Ophtalmologue', 'Ophtalmologue'),
        ('Gynécologue', 'Gynécologue'),
        ('Orthopédiste', 'Orthopédiste'),
        ('Neurologue', 'Neurologue'),
        ('Psychiatre', 'Psychiatre'),
        ('Urologue', 'Urologue'),
    ]

    GOUVERNORAT_CHOICES = [
        ('Ariana', 'Ariana'), ('Béja', 'Béja'), ('Ben Arous', 'Ben Arous'), ('Bizerte', 'Bizerte'),
        ('Gabès', 'Gabès'), ('Gafsa', 'Gafsa'), ('Jendouba', 'Jendouba'), ('Kairouan', 'Kairouan'),
        ('Kasserine', 'Kasserine'), ('Kébili', 'Kébili'), ('Kef', 'Kef'), ('Mahdia', 'Mahdia'),
        ('Manouba', 'Manouba'), ('Médenine', 'Médenine'), ('Monastir', 'Monastir'), ('Nabeul', 'Nabeul'),
        ('Sfax', 'Sfax'), ('Sidi Bouzid', 'Sidi Bouzid'), ('Siliana', 'Siliana'), ('Sousse', 'Sousse'),
        ('Tataouine', 'Tataouine'), ('Tozeur', 'Tozeur'), ('Tunis', 'Tunis'), ('Zaghouan', 'Zaghouan')
    ]

    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    genre = models.CharField(max_length=10, choices=GENRE_CHOICES)
    date_naissance = models.DateField()
    telephone = models.CharField(max_length=15, unique=True)
    email = models.EmailField(unique=True)
    localisation = models.CharField(max_length=100, choices=GOUVERNORAT_CHOICES)
    specialite = models.CharField(max_length=100, choices=SPECIALITE_CHOICES)
    password = models.CharField(max_length=128)  # Stocké sous forme hachée
    date_joined = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        """Hacher le mot de passe avant de sauvegarder l'instance."""
        if not self.password.startswith('pbkdf2_sha256$'):  # Évite de le hacher plusieurs fois
            self.password = make_password(self.password)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.nom} {self.prenom} - {self.specialite} ({self.localisation})"
 

    

    
class Client(models.Model):
    nom = models.CharField(max_length=100)
    prenom = models.CharField(max_length=100)
    genre = models.CharField(max_length=10, choices=GENRE_CHOICES)
    date_naissance = models.DateField()
    telephone = models.CharField(max_length=15, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)

    def save(self, *args, **kwargs):
        if not self.password.startswith('pbkdf2_sha256$'):
            self.password = make_password(self.password)
        super(Client, self).save(*args, **kwargs)

    def __str__(self):
        return f"{self.nom} {self.prenom}"
    

class Disponibilite(models.Model):
    docteur = models.OneToOneField("Docteur", on_delete=models.CASCADE, related_name="disponibilites")

    debut_lundi = models.TimeField(null=True, blank=True)
    fin_lundi = models.TimeField(null=True, blank=True)

    debut_mardi = models.TimeField(null=True, blank=True)
    fin_mardi = models.TimeField(null=True, blank=True)

    debut_mercredi = models.TimeField(null=True, blank=True)
    fin_mercredi = models.TimeField(null=True, blank=True)

    debut_jeudi = models.TimeField(null=True, blank=True)
    fin_jeudi = models.TimeField(null=True, blank=True)

    debut_vendredi = models.TimeField(null=True, blank=True)
    fin_vendredi = models.TimeField(null=True, blank=True)

    debut_samedi = models.TimeField(null=True, blank=True)
    fin_samedi = models.TimeField(null=True, blank=True)

    debut_dimanche = models.TimeField(null=True, blank=True)
    fin_dimanche = models.TimeField(null=True, blank=True)

    def __str__(self):
        return f"Disponibilités de {self.docteur.nom} {self.docteur.prenom}"
    
class RendezVous(models.Model):
    STATUT_CHOICES = [
        ('En attente', 'En attente'),
        ('Confirmé', 'Confirmé'),
        ('Annulé', 'Annulé'),
    ]
    docteur = models.ForeignKey('Docteur', on_delete=models.CASCADE)
    client = models.ForeignKey('Client', on_delete=models.CASCADE, null=True, blank=True)  # Un client peut être lié
    nom = models.CharField(max_length=10, null=True, blank=True)
    prenom = models.CharField(max_length=10, null=True, blank=True)
    genre = models.CharField(max_length=10, null=True, blank=True)
    date_naissance = models.DateField(null=True, blank=True)
    telephone = models.CharField(max_length=10, null=True, blank=True)
    description_maladie = models.TextField(blank=True, null=True)
    date = models.DateField()  # Date du rendez-vous
    heure = models.TimeField()  # Heure du rendez-vous
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='En attente')


    def __str__(self):
       return f"{self.nom} {self.prenom} - {self.date} {self.heure}"
    

class Notification(models.Model):
    doctor = models.ForeignKey(Docteur, on_delete=models.CASCADE)
    message = models.TextField()
    appointment_data = models.JSONField()  # Stocke les infos du formulaire
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)