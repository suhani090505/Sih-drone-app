import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/mission_model.dart';
import '../services/drone_service.dart';

class AddMissionModal extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onClose;

  const AddMissionModal({
    super.key,
    required this.isDarkMode,
    required this.onClose,
  });

  @override
  State<AddMissionModal> createState() => _AddMissionModalState();
}

class _AddMissionModalState extends State<AddMissionModal> {
  String step = 'form'; // form, preview, loading
  bool isDraft = false;
  bool showManualInput = false;
  
  String location = '';
  String coordinates = '';
  String packageType = '';
  String urgency = 'Medium';
  String pilot = '';
  String notes = '';
  bool isManualLocation = false;
  bool isLoading = true;
  
  final DroneService _droneService = DroneService();
  
  List<Map<String, dynamic>> packageOptions = [];
  List<Map<String, dynamic>> pilotOptions = [];
  List<Map<String, dynamic>> disasterZones = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _droneService.getPackageTypes(),
        _droneService.getUsers(),
        _droneService.getDisasterZones(),
      ]);
      
      if (mounted) {
        final appState = context.read<AppStateProvider>();
        
        setState(() {
          if (results[0]['success']) packageOptions = List<Map<String, dynamic>>.from(results[0]['data']);
          
          // Combine API pilots with local pilots
          pilotOptions = [];
          if (results[1]['success']) {
            pilotOptions.addAll((results[1]['users'] as List).map((user) => {
              'value': 'api-pilot-${user['id']}',
              'name': user['username'],
              'status': user['status'],
              'experience': user['experience'],
            }).toList());
          }
          
          // Add local pilots from app state
          pilotOptions.addAll(appState.pilots.map((pilot) => {
            'value': 'local-pilot-${pilot.id}',
            'name': pilot.name,
            'status': 'Available',
            'experience': 'License: ${pilot.licenseId}',
          }).toList());
          
          if (results[2]['success']) disasterZones = List<Map<String, dynamic>>.from(results[2]['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  void handleLocationChange(String value) {
    if (value == 'manual') {
      setState(() {
        showManualInput = true;
        location = '';
        coordinates = '';
        isManualLocation = true;
      });
      return;
    }

    final zone = disasterZones.firstWhere((z) => z['value'] == value, orElse: () => <String, dynamic>{});
    setState(() {
      location = value;
      coordinates = zone['coords'] ?? '';
      isManualLocation = false;
    });
  }

  void handleManualLocationSubmit() {
    if (location.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }
    
    // Generate dummy coordinates for manual location
    final coords = '${(42.3 + (DateTime.now().millisecond % 100) * 0.001).toStringAsFixed(4)}° N, ${(71.0 + (DateTime.now().millisecond % 100) * 0.001).toStringAsFixed(4)}° W';
    
    setState(() {
      coordinates = coords;
      isManualLocation = true;
      showManualInput = false;
    });
  }

  void handleUrgencyChange(String value) {
    setState(() {
      urgency = value;
      // Auto-suggest package based on urgency
      switch (value) {
        case 'High':
          packageType = 'medical';
          break;
        case 'Medium':
          packageType = 'food';
          break;
        case 'Low':
          packageType = 'communication';
          break;
      }
    });
  }

  void handlePreview() {
    if (location.isEmpty || packageType.isEmpty || pilot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    setState(() {
      step = 'preview';
    });
  }

  void handleConfirm() async {
    setState(() {
      step = 'loading';
    });
    
    try {
      // Parse coordinates
      final coordParts = coordinates.split(',');
      final lat = double.parse(coordParts[0].replaceAll(RegExp(r'[^0-9.-]'), ''));
      final lng = double.parse(coordParts[1].replaceAll(RegExp(r'[^0-9.-]'), ''));
      
      final selectedPackage = packageOptions.firstWhere((pkg) => pkg['value'] == packageType);
      
      // Create mission via API
      int? assignedPilotId;
      if (pilot.isNotEmpty && pilot.startsWith('api-pilot-')) {
        assignedPilotId = int.tryParse(pilot.split('-')[2]);
      }
      
      final result = await _droneService.createMission(
        latitude: lat,
        longitude: lng,
        packageDetails: {
          'type': packageType,
          'label': selectedPackage['label'],
          'weight': selectedPackage['weight'],
          'icon': selectedPackage['icon'],
        },
        urgencyLevel: urgency,
        assignedPilot: assignedPilotId,
        additionalNote: notes,
      );
      
      if (result['success']) {
        // Create local mission data for UI
        final selectedPilot = pilotOptions.firstWhere((p) => p['value'] == pilot);
        final selectedZone = disasterZones.firstWhere((z) => z['value'] == location, orElse: () => <String, dynamic>{});
        
        final newMission = MissionData(
          droneId: result['data']['drone']['id'],
          status: MissionStatus.inTransit,
          mission: Mission(
            droneModel: 'MQ-9 Guardian',
            payload: [
              PayloadItem(
                name: selectedPackage['label']!,
                weight: selectedPackage['weight']!,
                priority: urgency == 'High' ? Priority.high : urgency == 'Medium' ? Priority.medium : Priority.low,
              ),
            ],
            recipient: Recipient(
              name: selectedPilot['name']!,
              contact: '+1 (555) 123-4567',
              location: isManualLocation ? location : (selectedZone['label'] ?? location),
            ),
            telemetry: Telemetry(
              battery: 100,
              altitude: '0 ft',
              speed: '0 mph',
              connectivity: Connectivity.strong,
            ),
            liveLocation: LiveLocation(
              coordinates: coordinates,
              lastUpdate: 'Just launched',
              distanceToDestination: 'Calculating...',
            ),
          ),
        );

        if (mounted) {
          context.read<AppStateProvider>().addMission(newMission);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mission deployed successfully!')),
          );
          widget.onClose();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          step = 'form';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              minWidth: 300,
              minHeight: 400,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: widget.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            step == 'form' ? 'Create New Mission' : 
                            step == 'preview' ? 'Confirm Mission' : 'Deploying Mission',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode ? Colors.white : const Color(0xFF212121),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: Icon(
                            Icons.close,
                            color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: isLoading ? _buildDataLoading() :
                             step == 'form' ? _buildForm() : 
                             step == 'preview' ? _buildPreview() : _buildLoading(),
                    ),
                  ),
                  
                  // Footer
                  if (step != 'loading')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: widget.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (step == 'form')
                            OutlinedButton.icon(
                              onPressed: () {
                                isDraft = true;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mission saved as draft')),
                                );
                                widget.onClose();
                              },
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save as Draft'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                                side: BorderSide(
                                  color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
                                ),
                              ),
                            ),
                          if (step == 'preview')
                            OutlinedButton(
                              onPressed: () => setState(() => step = 'form'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                                side: BorderSide(
                                  color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
                                ),
                              ),
                              child: const Text('Back to Edit'),
                            ),
                          const Spacer(),
                          if (step == 'form')
                            ElevatedButton.icon(
                              onPressed: handlePreview,
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('Preview Mission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2),
                                foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          if (step == 'preview')
                            ElevatedButton.icon(
                              onPressed: handleConfirm,
                              icon: const Icon(Icons.send, size: 16),
                              label: const Text('Deploy Mission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2),
                                foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Section
        _buildSectionTitle('Disaster Zone Location *', Icons.location_on),
        const SizedBox(height: 12),
        
        if (showManualInput) ...[
          TextField(
            onChanged: (value) => setState(() => location = value),
            decoration: InputDecoration(
              hintText: 'Enter location manually...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
                ),
              ),
              filled: true,
              fillColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
            ),
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: handleManualLocationSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2),
                    foregroundColor: widget.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: const Text('Confirm Location'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() {
                  showManualInput = false;
                  location = '';
                  coordinates = '';
                  isManualLocation = false;
                }),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ] else ...[
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonFormField<String>(
                initialValue: isManualLocation ? null : (location.isEmpty ? null : location),
                hint: Text(isManualLocation ? location : 'Select or enter location...'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
                    ),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                ),
                dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
                isExpanded: true,
                items: [
                  ...disasterZones.map((zone) => DropdownMenuItem(
                    value: zone['value'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(zone['label']!, overflow: TextOverflow.ellipsis),
                        Text(
                          zone['coords']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )),
                  DropdownMenuItem(
                    value: 'manual',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Enter Location Manually'),
                              Text(
                                'Type custom location name',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => handleLocationChange(value!),
              );
            },
          ),
        ],
        
        // Map Preview
        if (coordinates.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B5563),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Map Preview',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const Positioned(
                  top: 8,
                  left: 8,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      coordinates,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Package Details
        _buildSectionTitle('Package Details *', Icons.inventory),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: packageType.isEmpty ? null : packageType,
          hint: const Text('Select package type...'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
              ),
            ),
            filled: true,
            fillColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          ),
          dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
          isExpanded: true,
          items: packageOptions.map((pkg) => DropdownMenuItem<String>(
            value: pkg['value'] as String,
            child: Row(
              children: [
                Text(pkg['icon']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pkg['label']!, overflow: TextOverflow.ellipsis),
                      Text(
                        'Weight: ${pkg['weight']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: (value) => setState(() => packageType = value!),
        ),
        
        const SizedBox(height: 24),
        
        // Urgency Level
        _buildSectionTitle('Urgency Level *', Icons.warning),
        const SizedBox(height: 12),
        Row(
          children: ['High', 'Medium', 'Low'].map((level) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => handleUrgencyChange(level),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: urgency == level 
                          ? (widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2))
                          : (widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7)),
                      width: urgency == level ? 2 : 1,
                    ),
                    color: urgency == level 
                        ? (widget.isDarkMode ? const Color(0xFF03DAC6).withValues(alpha: 0.1) : const Color(0xFF1976D2).withValues(alpha: 0.1))
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: urgency == level 
                                ? (widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2))
                                : (widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
                            width: 2,
                          ),
                          color: urgency == level 
                              ? (widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2))
                              : Colors.transparent,
                        ),
                        child: urgency == level 
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          level,
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight: urgency == level ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Assign Pilot
        _buildSectionTitle('Assign Pilot/Operator *', Icons.person),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: pilot.isEmpty ? null : pilot,
          hint: const Text('Select pilot or operator...'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
              ),
            ),
            filled: true,
            fillColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          ),
          dropdownColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
          isExpanded: true,
          items: pilotOptions.map((p) => DropdownMenuItem<String>(
            value: p['value'] as String,
            enabled: p['status'] == 'Available',
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p['name']!,
                        style: TextStyle(
                          color: p['status'] == 'Available' 
                              ? (widget.isDarkMode ? Colors.white : Colors.black)
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${p['experience']} experience',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: p['status'] == 'Available' ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p['status']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: p['status'] == 'Available' ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: (value) => setState(() => pilot = value!),
        ),
        
        const SizedBox(height: 24),
        
        // Notes
        _buildSectionTitle('Additional Notes (Optional)', Icons.note),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => setState(() => notes = value),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter any additional mission details, special instructions, or notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFC7C7C7),
              ),
            ),
            filled: true,
            fillColor: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          ),
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDataLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Loading mission data...',
          style: TextStyle(
            fontSize: 16,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF212121),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final selectedPackage = packageOptions.firstWhere((pkg) => pkg['value'] == packageType);
    final selectedPilot = pilotOptions.firstWhere((p) => p['value'] == pilot);
    final selectedZone = disasterZones.firstWhere((z) => z['value'] == location, orElse: () => <String, dynamic>{});
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDarkMode ? const Color(0xFF383838) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mission Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : const Color(0xFF212121),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPreviewItem(
                  'Location',
                  isManualLocation ? location : (selectedZone['label'] ?? location),
                  coordinates + (isManualLocation ? ' • Custom Location' : ''),
                ),
              ),
              Expanded(
                child: _buildPreviewItem(
                  'Package',
                  selectedPackage['label']!,
                  selectedPackage['weight']!,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildPreviewItem('Urgency', urgency, ''),
              ),
              Expanded(
                child: _buildPreviewItem('Pilot', selectedPilot['name']!, ''),
              ),
            ],
          ),
          
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPreviewItem('Notes', notes, ''),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF212121),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isDarkMode ? const Color(0xFF03DAC6) : const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Deploying mission...',
          style: TextStyle(
            fontSize: 16,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preparing drone, calculating route, and notifying pilot',
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F6368),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}