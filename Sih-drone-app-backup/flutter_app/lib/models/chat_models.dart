class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      messageCount: json['message_count'],
    );
  }
}

class ChatMessage {
  final String id;
  final String type;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<QuickActionData>? quickActions;

  ChatMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.metadata,
    this.quickActions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
      quickActions: json['quick_actions'] != null
          ? (json['quick_actions'] as List)
              .map((qa) => QuickActionData.fromJson(qa))
              .toList()
          : null,
    );
  }

  bool get isBot => type == 'bot';
  bool get isUser => type == 'user';
  bool get isSystem => type == 'system';
}

class QuickActionData {
  final String type;
  final String label;
  final String icon;
  final Map<String, dynamic>? data;

  QuickActionData({
    required this.type,
    required this.label,
    required this.icon,
    this.data,
  });

  factory QuickActionData.fromJson(Map<String, dynamic> json) {
    return QuickActionData(
      type: json['type'],
      label: json['label'],
      icon: json['icon'],
      data: json['data'],
    );
  }
}