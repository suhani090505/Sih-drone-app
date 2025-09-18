# Generated migration for FleetStatistics model

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='FleetStatistics',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('number_of_active_drones', models.IntegerField(default=0)),
                ('number_of_successful_deliveries', models.IntegerField(default=0)),
                ('number_of_unsuccessful_deliveries', models.IntegerField(default=0)),
                ('average_response_time', models.FloatField(default=0.0, help_text='Average response time in minutes')),
                ('month', models.DateField(help_text='Month for which these stats are recorded')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'ordering': ['-month'],
            },
        ),
        migrations.AlterUniqueTogether(
            name='fleetstatistics',
            unique_together={('month',)},
        ),
    ]