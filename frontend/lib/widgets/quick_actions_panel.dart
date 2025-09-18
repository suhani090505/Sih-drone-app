import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class QuickActionsPanel extends StatelessWidget {
  final bool isDarkMode;
  final String? sessionId;
  final Function(String)? onActionExecuted;

  const QuickActionsPanel({
    super.key,
    required this.isDarkMode,
    this.sessionId,
    this.onActionExecuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionButton(
                context,
                'Track Drones',
                Icons.location_on,
                'track_drone',
                Colors.blue,
              ),
              _buildQuickActionButton(
                context,
                'Fleet Status',
                Icons.flight,
                'fleet_status',
                Colors.green,
              ),
              _buildQuickActionButton(
                context,
                'View Reports',
                Icons.assessment,
                'view_reports',
                Colors.purple,
              ),
              _buildQuickActionButton(
                context,
                'Check Weather',
                Icons.wb_sunny,
                'check_weather',
                Colors.orange,
              ),
              _buildQuickActionButton(
                context,
                'Inventory',
                Icons.inventory,
                'inventory_check',
                Colors.brown,
              ),
              _buildQuickActionButton(
                context,
                'Emergency',
                Icons.emergency,
                'emergency_alert',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    String actionType,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _executeQuickAction(context, actionType, label),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _executeQuickAction(BuildContext context, String actionType, String label) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Executing $label...'),
          duration: const Duration(seconds: 1),
        ),
      );

      final response = await ChatService.executeQuickAction(
        actionType: actionType,
        sessionId: sessionId,
      );

      // Show notification
      NotificationService.showChatbotAlert(
        message: response['message'] ?? 'Action completed successfully',
        actionData: response,
      );

      // Handle specific actions
      if (response['action'] == 'navigate' && response['target'] != null) {
        _handleNavigation(context, response['target']);
      } else if (response['action'] == 'modal') {
        _showActionModal(context, response);
      } else if (response['action'] == 'alert') {
        _showAlert(context, response);
      }

      // Notify parent widget
      onActionExecuted?.call(actionType);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to execute $label: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNavigation(BuildContext context, String target) {
    // Handle navigation based on target
    switch (target) {
      case '/tracking':
        // Navigate to tracking screen
        Navigator.pushNamed(context, '/tracking');
        break;
      case '/reports':
        // Navigate to reports screen
        Navigator.pushNamed(context, '/reports');
        break;
      case '/fleet':
        // Navigate to fleet screen
        Navigator.pushNamed(context, '/fleet');
        break;
      case '/inventory':
        // Navigate to inventory screen
        Navigator.pushNamed(context, '/inventory');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation to $target not implemented')),
        );
    }
  }

  void _showActionModal(BuildContext context, Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Quick Action Result',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response['message'] ?? 'Action completed',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            if (response['data'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Details:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 8),
              ...response['data'].entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFBB86FC) : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlert(BuildContext context, Map<String, dynamic> response) {
    final priority = response['priority'] ?? 'normal';
    final color = priority == 'high' ? Colors.red : Colors.orange;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning, color: color),
            const SizedBox(width: 8),
            Text(
              priority == 'high' ? 'URGENT ALERT' : 'Alert',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          response['message'] ?? 'Alert triggered',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Acknowledge',
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}