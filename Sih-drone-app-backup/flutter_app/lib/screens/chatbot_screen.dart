import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';
import '../services/chat_service.dart';
import '../models/chat_models.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final String action;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.action,
  });
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;
  final List<QuickAction>? quickActions;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.quickActions,
  });
}

class ChatbotScreen extends StatefulWidget {
  final bool isDarkMode;

  const ChatbotScreen({super.key, required this.isDarkMode});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isListening = false;
  String? _currentSessionId;
  bool _isConnected = false;

  final List<String> suggestions = [
    'Drone Status',
    'Delivery Issues',
    'Update Contact',
    'Weather Check'
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your AI assistant for drone operations. I can help you track deliveries, check drone status, analyze performance, and resolve issues. How can I assist you today?",
      isBot: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      quickActions: [
        const QuickAction(label: 'Track Drone', icon: Icons.location_on, action: 'track'),
        const QuickAction(label: 'View Reports', icon: Icons.bar_chart, action: 'reports'),
        const QuickAction(label: 'Contact Support', icon: Icons.phone, action: 'support'),
      ],
    ),
  ];

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkMode
                    ? [const Color(0xFF1E1E1E), const Color(0xFF232323)]
                    : [Colors.grey.shade800, Colors.grey.shade700],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.isDarkMode
                                ? [const Color(0xFFBB86FC), const Color(0xFFBB86FC).withValues(alpha: 0.8)]
                                : [Colors.blue.shade500, Colors.purple.shade600],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          size: 24,
                          color: widget.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Ask anything about your drone operations',
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                }
                return _buildTypingIndicator();
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: widget.isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              children: [
                // Suggestions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((suggestion) => StyledBadge(
                    backgroundColor: widget.isDarkMode 
                        ? const Color(0xFF2C2C2C)
                        : Colors.grey.shade100,
                    textColor: widget.isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    child: Text(suggestion),
                  )).toList(),
                ),
                const SizedBox(height: 12),

                // Message Input
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: TextStyle(
                                  color: widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type your query...',
                                  hintStyle: TextStyle(
                                    color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: _isListening
                                    ? (widget.isDarkMode ? const Color(0xFFCF6679) : Colors.red)
                                    : (widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isListening = !_isListening;
                                  if (_isListening) {
                                    // Simulate voice input after 2 seconds
                                    Future.delayed(const Duration(seconds: 2), () {
                                      _messageController.text = 'Where is Drone A3 now?';
                                      setState(() => _isListening = false);
                                    });
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isDarkMode
                              ? [const Color(0xFFBB86FC), const Color(0xFFBB86FC).withValues(alpha: 0.8)]
                              : [Colors.blue.shade500, Colors.purple.shade600],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Listening Indicator
                if (_isListening) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.isDarkMode ? const Color(0xFFCF6679) : Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const PulsingDot(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Listening...',
                        style: TextStyle(
                          color: widget.isDarkMode ? const Color(0xFFCF6679) : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isBot) _buildAvatar(true),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isBot
                        ? null
                        : LinearGradient(
                            colors: widget.isDarkMode
                                ? [const Color(0xFFBB86FC), const Color(0xFFBB86FC).withValues(alpha: 0.8)]
                                : [Colors.blue.shade500, Colors.purple.shade600],
                          ),
                    color: message.isBot
                        ? (widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: message.isBot
                        ? Border.all(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade200,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isBot
                              ? (widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade900)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: message.isBot
                              ? (widget.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!message.isBot) _buildAvatar(false),
            ],
          ),
          if (message.quickActions != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: message.isBot ? 48 : 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.quickActions!.map((action) => StyledButton(
                  onPressed: () => _handleQuickAction(action.action),
                  backgroundColor: widget.isDarkMode
                      ? const Color(0xFF2C2C2C)
                      : Colors.white,
                  textColor: widget.isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade700,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.icon,
                        size: 16,
                        color: widget.isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(action.label),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isBot) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBot
              ? (widget.isDarkMode
                  ? [const Color(0xFF03DAC6), const Color(0xFF03DAC6).withValues(alpha: 0.8)]
                  : [Colors.grey.shade400, Colors.grey.shade500])
              : (widget.isDarkMode
                  ? [const Color(0xFFBB86FC), const Color(0xFFBB86FC).withValues(alpha: 0.8)]
                  : [Colors.blue.shade500, Colors.purple.shade600]),
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isBot ? Icons.smart_toy : Icons.person,
        size: 16,
        color: widget.isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          _buildAvatar(true),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(100),
                _buildDot(200),
                const SizedBox(width: 8),
                Text(
                  'AI is thinking...',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: PulsingDot(
        color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
        delay: delay,
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await ChatService.sendMessage(
        message: userMessage,
        sessionId: _currentSessionId,
      );

      setState(() {
        _isTyping = false;
        _currentSessionId = response['session_id'];
        
        final quickActions = (response['quick_actions'] as List?)
            ?.map((qa) => QuickAction(
                  label: qa['label'],
                  icon: _getIconFromString(qa['icon']),
                  action: qa['type'],
                ))
            .toList();

        _messages.add(ChatMessage(
          text: response['content'],
          isBot: true,
          timestamp: DateTime.now(),
          quickActions: quickActions,
        ));
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: 'Sorry, I\'m having trouble connecting. Please try again.',
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _handleQuickAction(String action) async {
    try {
      final response = await ChatService.executeQuickAction(
        actionType: action,
        sessionId: _currentSessionId,
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response['message'] ?? 'Processing your request...',
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();

      // Handle navigation or modal actions
      if (response['action'] == 'navigate' && response['target'] != null) {
        // Navigate to target screen
        _handleNavigation(response['target']);
      } else if (response['action'] == 'modal') {
        // Show modal with data
        _showActionModal(response);
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Unable to process that action right now. Please try again.',
          isBot: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'location_on': return Icons.location_on;
      case 'flight': return Icons.flight;
      case 'warning': return Icons.warning;
      case 'bar_chart': return Icons.bar_chart;
      case 'assessment': return Icons.assessment;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'emergency': return Icons.emergency;
      case 'inventory': return Icons.inventory;
      case 'phone': return Icons.phone;
      case 'near_me': return Icons.near_me;
      case 'route': return Icons.route;
      case 'analytics': return Icons.analytics;
      case 'download': return Icons.download;
      case 'trending_up': return Icons.trending_up;
      case 'flight_takeoff': return Icons.flight_takeoff;
      case 'notification_important': return Icons.notification_important;
      case 'message': return Icons.message;
      case 'support_agent': return Icons.support_agent;
      case 'add': return Icons.add;
      case 'local_shipping': return Icons.local_shipping;
      case 'priority_high': return Icons.priority_high;
      default: return Icons.help;
    }
  }

  void _handleNavigation(String target) {
    // Handle navigation based on target
    switch (target) {
      case '/tracking':
        // Navigate to tracking screen
        break;
      case '/reports':
        // Navigate to reports screen
        break;
      case '/fleet':
        // Navigate to fleet screen
        break;
      case '/inventory':
        // Navigate to inventory screen
        break;
    }
  }

  void _showActionModal(Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Action'),
        content: Text(response['message'] ?? 'Action completed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Set auth token if available
    // ChatService.setAuthToken('your-jwt-token');
    setState(() {
      _isConnected = true;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class PulsingDot extends StatefulWidget {
  final Color? color;
  final int delay;

  const PulsingDot({super.key, this.color, this.delay = 0});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      _controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color ?? Colors.grey.shade400,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
