from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from fleet_app.models import FleetStatistics

class Command(BaseCommand):
    help = 'Populate fleet statistics with sample data for the last 12 months'

    def handle(self, *args, **options):
        self.stdout.write('Populating fleet statistics...')
        
        # Generate data for last 12 months
        current_date = timezone.now().replace(day=1).date()
        
        for i in range(12):
            month_date = current_date - timedelta(days=30 * i)
            month_date = month_date.replace(day=1)
            
            # Generate sample data
            active_drones = 10 + (i % 5)
            successful_deliveries = 80 + (i * 10)
            unsuccessful_deliveries = 5 + (i % 3)
            avg_response_time = 12.0 + (i * 0.5)
            
            stats, created = FleetStatistics.objects.update_or_create(
                month=month_date,
                defaults={
                    'number_of_active_drones': active_drones,
                    'number_of_successful_deliveries': successful_deliveries,
                    'number_of_unsuccessful_deliveries': unsuccessful_deliveries,
                    'average_response_time': avg_response_time
                }
            )
            
            action = "Created" if created else "Updated"
            self.stdout.write(
                f'{action} stats for {month_date.strftime("%B %Y")}: '
                f'{active_drones} active drones, {successful_deliveries} successful deliveries'
            )
        
        self.stdout.write(
            self.style.SUCCESS('Successfully populated fleet statistics!')
        )