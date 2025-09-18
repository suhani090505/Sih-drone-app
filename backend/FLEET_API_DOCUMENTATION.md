# Fleet Management API Documentation

## Overview
Extended fleet management APIs to support fleet statistics tracking and reporting with month-wise aggregation.

## New Endpoints

### 1. GET /api/fleet/statistics/
**Description:** Fetch fleet statistics with optional month-wise filtering

**Parameters:**
- `month` (optional): Filter by specific month in YYYY-MM format

**Response Format:**
```json
{
  "monthly_stats": [
    {
      "id": 1,
      "number_of_active_drones": 15,
      "number_of_successful_deliveries": 120,
      "number_of_unsuccessful_deliveries": 8,
      "average_response_time": 12.5,
      "month": "2024-01-01",
      "month_display": "January 2024",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "aggregated_stats": {
    "total_active_drones": 180,
    "total_successful_deliveries": 1440,
    "total_unsuccessful_deliveries": 96,
    "average_response_time": 13.25,
    "success_rate": 93.75
  }
}
```

**Examples:**
```bash
# Get all statistics (last 12 months)
GET /api/fleet/statistics/

# Get statistics for specific month
GET /api/fleet/statistics/?month=2024-01
```

### 2. POST/PUT /api/fleet/statistics/manage/
**Description:** Create or update fleet statistics for a specific month

**Request Body:**
```json
{
  "number_of_active_drones": 15,
  "number_of_successful_deliveries": 120,
  "number_of_unsuccessful_deliveries": 8,
  "average_response_time": 12.5,
  "month": "2024-01"  // Optional, defaults to current month
}
```

**Response:**
```json
{
  "message": "Fleet statistics updated successfully",
  "data": {
    "id": 1,
    "number_of_active_drones": 15,
    "number_of_successful_deliveries": 120,
    "number_of_unsuccessful_deliveries": 8,
    "average_response_time": 12.5,
    "month": "2024-01-01",
    "month_display": "January 2024",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

## Existing Endpoints (Unchanged)

### GET /api/fleet/
**Description:** Get current fleet status and drone distribution

### GET /api/fleet/status/
**Description:** Detailed fleet status (alias for /api/fleet/)

## Database Schema

### FleetStatistics Model
```python
class FleetStatistics(models.Model):
    number_of_active_drones = models.IntegerField(default=0)
    number_of_successful_deliveries = models.IntegerField(default=0)
    number_of_unsuccessful_deliveries = models.IntegerField(default=0)
    average_response_time = models.FloatField(default=0.0)  # in minutes
    month = models.DateField()  # First day of the month
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

## Integration Points

### Dashboard Integration
The dashboard can fetch fleet statistics using:
```javascript
// Get current month stats
fetch('/api/fleet/statistics/')

// Get specific month stats
fetch('/api/fleet/statistics/?month=2024-01')
```

### Reports Integration
The reports screen can use the same endpoint with month filtering:
```javascript
// Get month-wise data for charts
fetch('/api/fleet/statistics/')  // Returns last 12 months
```

## Management Commands

### Populate Sample Data
```bash
python manage.py populate_fleet_stats
```

## Testing

Run the test script:
```bash
python test_fleet_api.py
```

## Migration

Run migrations to create the new FleetStatistics table:
```bash
python manage.py makemigrations fleet_app
python manage.py migrate
```

## Notes

1. **Backward Compatibility:** All existing APIs remain unchanged
2. **Data Aggregation:** Statistics are automatically calculated and cached monthly
3. **Performance:** Month-wise storage enables efficient reporting queries
4. **Extensibility:** Model can be easily extended with additional metrics
5. **Admin Interface:** FleetStatistics can be managed through Django admin