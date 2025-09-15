from django.urls import path
from . import views

# Report endpoints under /api/reports/
urlpatterns = [
    path('', views.reports_overview, name='reports_list'),
    path('overview/', views.reports_overview, name='reports_overview'),
    path('export/', views.export_report, name='reports_export'),
]