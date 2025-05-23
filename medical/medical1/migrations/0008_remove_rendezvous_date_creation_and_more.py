# Generated by Django 5.1.5 on 2025-03-24 01:04

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('medical1', '0007_disponibilite_rendezvous'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='rendezvous',
            name='date_creation',
        ),
        migrations.RemoveField(
            model_name='rendezvous',
            name='patient',
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='client',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to='medical1.client'),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='date_naissance',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='description_maladie',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='genre',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='nom',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='prenom',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AddField(
            model_name='rendezvous',
            name='telephone',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
        migrations.AlterField(
            model_name='rendezvous',
            name='docteur',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='medical1.docteur'),
        ),
    ]
