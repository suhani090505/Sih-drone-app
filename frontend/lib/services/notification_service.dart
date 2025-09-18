import 'package:flutter/material.dart';

class NotificationService {
  static final List<AppNotification> _notifications = [];
  static final List<VoidCallback> _listeners = [];

  static List<AppNotification> get notifications => List.unmodifiable(_notifications);

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  static void showNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? data,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );

    _notifications.insert(0, notification);
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }

    _notifyListeners();
  }

  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  static void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  static int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Chatbot-specific notifications
  static void showChatbotAlert({
    required String message,
    NotificationType type = NotificationType.chatbot,
    Map<String, dynamic>? actionData,
  }) {
    showNotification(
      title: 'AI Assistant',
      message: message,
      type: type,
      data: actionData,
    );
  }

  static void showEmergencyAlert({
    required String message,
    Map<String, dynamic>? emergencyData,
  }) {
    showNotification(
      title: 'EMERGENCY ALERT',
      message: message,
      type: NotificationType.emergency,
      data: emergencyData,
    );
  }

  static void showDroneUpdate({
    required String droneId,
    required String status,
    Map<String, dynamic>? droneData,
  }) {
    showNotification(
      title: 'Drone Update',
      message: 'Drone $droneId: $status',
      type: NotificationType.drone,
      data: droneData,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.emergency:
        return Icons.emergency;
      case NotificationType.drone:
        return Icons.flight;
      case NotificationType.chatbot:
        return Icons.smart_toy;
      case NotificationType.delivery:
        return Icons.local_shipping;
      case NotificationType.weather:
        return Icons.wb_sunny;
      case NotificationType.inventory:
        return Icons.inventory;
      case NotificationType.info:
      default:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.emergency:
        return Colors.red;
      case NotificationType.drone:
        return Colors.blue;
      case NotificationType.chatbot:
        return Colors.purple;
      case NotificationType.delivery:
        return Colors.green;
      case NotificationType.weather:
        return Colors.orange;
      case NotificationType.inventory:
        return Colors.brown;
      case NotificationType.info:
      default:
        return Colors.grey;
    }
  }
}

enum NotificationType {
  info,
  emergency,
  drone,
  chatbot,
  delivery,
  weather,
  inventory,
}