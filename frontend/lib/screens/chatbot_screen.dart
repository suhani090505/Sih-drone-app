import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  final bool isDarkMode;

  const ChatbotScreen({super.key, required this.isDarkMode});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showSections = true;
  String? _selectedSection;
  
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "How can I help you?",
      isBot: true,
      timestamp: DateTime.now(),
    ),
  ];

  final Map<String, List<String>> _sections = {
    'Navigation': [
      'Where is Manage Fleet?',
      'Where can I see Reports?',
      'How can I view the bar chart?',
      'Where is the Dashboard?',
      'How do I access Settings?',
    ],
    'Functionalities': [
      'How to add a mission?',
      'How to add a pilot?',
      'How to assign a mission?',
      'How to remove a mission?',
      'How to add a drone to fleet?',
    ],
    'Issues': [
      'Location not visible',
      'Map not visible',
      'App running slowly',
      'Drone not connecting',
      'Data not syncing',
    ],
    'General/Default': [
      'Help',
      'Settings',
      'Logout',
      'Profile',
      'Contact Support',
    ],
  };

  final Map<String, String> _answers = {
    'Where is Manage Fleet?': 'You can find Manage Fleet in the main navigation menu. Look for the fleet icon in the bottom navigation bar or in the side menu under "Fleet Management".',
    'Where can I see Reports?': 'Reports are available in the main menu. Tap on the "Reports" tab in the bottom navigation or find it in the side drawer menu with a chart icon.',
    'How can I view the bar chart?': 'Charts including bar charts are located in the Reports section. Navigate to Reports > Analytics to view various chart types for your drone data.',
    'Where is the Dashboard?': 'The Dashboard is typically the home screen when you open the app. You can also access it by tapping the "Home" or "Dashboard" icon in the main navigation.',
    'How do I access Settings?': 'Settings can be found by tapping your profile icon in the top-right corner, or look for the gear icon in the main menu.',
    'How to add a mission?': 'To add a mission, go to the Missions tab and tap the "+" button or "Add Mission" button. Fill in the mission details and save.',
    'How to add a pilot?': 'Go to Manage Fleet > Pilots section and tap "Add Pilot". Enter the pilot\'s details, certifications, and save.',
    'How to assign a mission?': 'Open the mission details, tap "Assign Pilot", select from the available pilots list, and confirm the assignment.',
    'How to remove a mission?': 'In the Missions list, find the mission you want to delete, swipe left on it, or tap the three dots menu and select "Delete Mission".',
    'How to add a drone to fleet?': 'In Manage Fleet, tap "Add Drone" or the "+" button, enter the drone specifications, serial number, and other details.',
    'Location not visible': 'The server is currently facing issues with location services. Please check back shortly as our team is working to resolve this.',
    'Map not visible': 'The server is currently facing issues with map services. Please try again in a few minutes. If the problem persists, contact support.',
    'App running slowly': 'The server is facing issues. Try closing and reopening the app. If issues persist, please try again later.',
    'Drone not connecting': 'The server is facing connectivity issues. Please check your internet connection and try again later.',
    'Data not syncing': 'The server is experiencing synchronization issues. Please try again in a few minutes.',
    'Help': 'You can access help by tapping "Help" in the main menu, or contact support through Settings > Support or the "Contact Us" option.',
    'Settings': 'Settings can be found by tapping your profile icon in the top-right corner, or look for the gear icon in the main menu.',
    'Logout': 'To log out, go to Settings or tap your profile icon, then select "Logout" or "Sign Out" at the bottom of the menu.',
    'Profile': 'Tap your profile icon, select "Profile" or "Account Settings", then edit your personal information and save changes.',
    'Contact Support': 'You can contact support through Settings > Support, the "Contact Us" option in the main menu, or tap the support icon.',
  };

  void _handleQuestionTap(String question) {
    setState(() {
      _messages.add(ChatMessage(
        text: question,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: _answers[question] ?? 'I\'m sorry, I don\'t have an answer for that question.',
        isBot: true,
        timestamp: DateTime.now(),
      ));
      _showSections = false;
      _selectedSection = null;
    });
    _scrollToBottom();
  }

  void _handleSectionTap(String section) {
    setState(() {
      _selectedSection = section;
      _showSections = false;
    });
  }

  void _goBack() {
    setState(() {
      if (_selectedSection != null) {
        _selectedSection = null;
        _showSections = true;
      } else {
        _showSections = true;
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                children: [
                  if (!_showSections || _selectedSection != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _goBack,
                    ),
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
                  Expanded(
                    child: Column(
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
                          _selectedSection ?? 'Ask anything about your drone operations',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade300,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _showSections
                ? _buildSectionsView()
                : _selectedSection != null
                    ? _buildQuestionsView()
                    : _buildChatView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMessageBubble(_messages.first),
        const SizedBox(height: 20),
        ..._sections.keys.map((section) => _buildSectionCard(section)),
      ],
    );
  }

  Widget _buildSectionCard(String section) {
    IconData icon;
    switch (section) {
      case 'Navigation':
        icon = Icons.navigation;
        break;
      case 'Functionalities':
        icon = Icons.build;
        break;
      case 'Issues':
        icon = Icons.error_outline;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: ListTile(
          leading: Icon(
            icon,
            color: widget.isDarkMode ? const Color(0xFFBB86FC) : Colors.blue,
          ),
          title: Text(
            section,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            size: 16,
          ),
          onTap: () => _handleSectionTap(section),
        ),
      ),
    );
  }

  Widget _buildQuestionsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _sections[_selectedSection]!
          .map((question) => _buildQuestionCard(question))
          .toList(),
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: ListTile(
          title: Text(
            question,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            size: 16,
          ),
          onTap: () => _handleQuestionTap(question),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDarkMode
                      ? [const Color(0xFFBB86FC), const Color(0xFFBB86FC).withValues(alpha: 0.8)]
                      : [Colors.blue.shade500, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: widget.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? (widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100)
                    : (widget.isDarkMode ? const Color(0xFFBB86FC) : Colors.blue),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isBot
                      ? (widget.isDarkMode ? Colors.white : Colors.black87)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}