import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/pilot_model.dart';

class AddPilotScreen extends StatefulWidget {
  final bool isDarkMode;

  const AddPilotScreen({super.key, required this.isDarkMode});

  @override
  State<AddPilotScreen> createState() => _AddPilotScreenState();
}

class _AddPilotScreenState extends State<AddPilotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _savePilot() {
    if (_formKey.currentState!.validate()) {
      final pilot = Pilot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        licenseId: _licenseController.text.trim(),
        createdAt: DateTime.now(),
      );

      context.read<AppStateProvider>().addPilot(pilot);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilot ${pilot.name} added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF374151),
          ),
        ),
        title: Text(
          'Add Pilot',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilot Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Pilot Name',
                        hintText: 'Enter pilot full name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: widget.isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF3B82F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF3B82F6),
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                        ),
                      ),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pilot name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // License ID Field
                    TextFormField(
                      controller: _licenseController,
                      decoration: InputDecoration(
                        labelText: 'License/ID Number',
                        hintText: 'Enter pilot license or ID number',
                        prefixIcon: Icon(
                          Icons.badge,
                          color: widget.isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF3B82F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF3B82F6),
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280),
                        ),
                      ),
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter license/ID number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Save Button
              ElevatedButton(
                onPressed: _savePilot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Pilot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}