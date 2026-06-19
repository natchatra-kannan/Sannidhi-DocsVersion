import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../repositories/interfaces.dart';
import '../../services/mock_data.dart';

class PunchuScreen extends ConsumerStatefulWidget {
  const PunchuScreen({super.key});

  @override
  ConsumerState<PunchuScreen> createState() => _PunchuScreenState();
}

class _PunchuScreenState extends ConsumerState<PunchuScreen> {
  String _selectedMode = 'Work From Home'; // 'Work From Home' or 'Present in Office'
  
  // Chennai Office Coordinates: "2nd floor, Park View Apartments, 85/94, Gopathy Narayana Rd, T. Nagar, Chennai, Tamil Nadu 600017"
  double _officeLat = 13.0405;
  double _officeLon = 80.2415;
  final String _officeAddress = "2nd floor, Park View Apartments, 85/94, Gopathy Narayana Rd, T. Nagar, Chennai";

  bool _isGettingLocation = false;
  double? _currentLat;
  double? _currentLon;
  String? _locationError;
  bool _isDemoMode = false; // When true, sets current location as office coordinates for easy testing
  
  final double _geofenceRadiusMeters = 100.0; // 100m radius

  @override
  void initState() {
    super.initState();
    // Pre-fetch location if "Present in Office" is default or for early detection
    _checkAndFetchLocation();
  }

  // Haversine formula to calculate distance in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R * 1000m (R = 6371 km)
  }

  Future<void> _checkAndFetchLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = "Location services are disabled. Please enable GPS.";
          _isGettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Location permissions are denied.";
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions are permanently denied. Please enable them in your settings.";
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentLat = position.latitude;
        _currentLon = position.longitude;
        _isGettingLocation = false;
        if (_isDemoMode) {
          _officeLat = position.latitude;
          _officeLon = position.longitude;
        }
      });
    } catch (e) {
      setState(() {
        _locationError = "Could not fetch location: $e";
        _isGettingLocation = false;
      });
    }
  }

  void _punchAttendance() async {
    final now = DateTime.now();
    
    // Evaluate isLate based on 10:30 AM + 20 mins grace period (10:50 AM)
    final bool isLate = now.hour > 10 || (now.hour == 10 && now.minute > 50);

    if (_selectedMode == 'Present in Office') {
      // Must fetch location and validate
      await _checkAndFetchLocation();

      if (_currentLat == null || _currentLon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location verification failed: ${_locationError ?? 'Unable to fetch coordinates.'}"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      double distance = _calculateDistance(_currentLat!, _currentLon!, _officeLat, _officeLon);
      bool inRange = distance <= _geofenceRadiusMeters;

      if (!inRange) {
        // Punched offline when not in office
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text("Verification Error"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You are outside the office geofence range!"),
                const SizedBox(height: 12),
                Text("Current location:\nLat: ${_currentLat!.toStringAsFixed(6)}, Lon: ${_currentLon!.toStringAsFixed(6)}"),
                const SizedBox(height: 8),
                Text("Office location:\nLat: ${_officeLat.toStringAsFixed(6)}, Lon: ${_officeLon.toStringAsFixed(6)}"),
                const SizedBox(height: 8),
                Text("Distance to office: ${distance.toStringAsFixed(1)} meters"),
                const SizedBox(height: 12),
                const Text(
                  "Note: To pass this check for testing, toggle 'Demo Mode' on to align the geofence to your current location.",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Success punch logic
    ref.read(attendanceStateProvider.notifier).punch(
      MockData.currentUser.fullName,
      _selectedMode,
      _selectedMode == 'Present in Office' ? _currentLat : null,
      _selectedMode == 'Present in Office' ? _currentLon : null,
      true, // Verified
      isLate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Punch successful! ${isLate ? 'Marked as LATE' : 'Marked as PRESENT'}",
            ),
          ],
        ),
        backgroundColor: isLate ? Colors.orange : SannidhiTheme.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final records = ref.watch(attendanceStateProvider);

    // Calculate geofence status
    double? distance;
    bool inRange = false;
    if (_currentLat != null && _currentLon != null) {
      distance = _calculateDistance(_currentLat!, _currentLon!, _officeLat, _officeLon);
      inRange = distance <= _geofenceRadiusMeters;
    }

    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Punchu Attendance',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Check in for the day either from Home or T. Nagar Office',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Punch Action Area
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Attendance Mode',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // Toggle tabs
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? SannidhiTheme.darkBg : SannidhiTheme.lightBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? SannidhiTheme.darkBorder : SannidhiTheme.lightBorder,
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedMode = 'Work From Home';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _selectedMode == 'Work From Home'
                                              ? SannidhiTheme.teal
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Work From Home',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedMode == 'Work From Home'
                                                ? Colors.white
                                                : (isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedMode = 'Present in Office';
                                        });
                                        _checkAndFetchLocation();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _selectedMode == 'Present in Office'
                                              ? SannidhiTheme.teal
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Present in Office',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _selectedMode == 'Present in Office'
                                                ? Colors.white
                                                : (isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Geofence status box for Office Punching
                            if (_selectedMode == 'Present in Office') ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: inRange
                                      ? Colors.green.withOpacity(0.08)
                                      : Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: inRange ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          inRange ? Icons.verified_user : Icons.gpp_bad_rounded,
                                          color: inRange ? Colors.green : Colors.redAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          inRange ? 'Office Range Verified' : 'Outside Office Range',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: inRange ? Colors.green : Colors.redAccent,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (_isGettingLocation)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        else
                                          IconButton(
                                            icon: const Icon(Icons.refresh, size: 18),
                                            onPressed: _checkAndFetchLocation,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Office Address: $_officeAddress",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    const Divider(height: 16),
                                    Text(
                                      "Office GPS: (${_officeLat.toStringAsFixed(4)}, ${_officeLon.toStringAsFixed(4)})",
                                      style: TextStyle(fontSize: 11, color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                                    ),
                                    if (_currentLat != null && _currentLon != null) ...[
                                      Text(
                                        "Your GPS: (${_currentLat!.toStringAsFixed(4)}, ${_currentLon!.toStringAsFixed(4)})",
                                        style: TextStyle(fontSize: 11, color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                                      ),
                                      Text(
                                        "Distance: ${distance?.toStringAsFixed(1)} meters (Limit: ${_geofenceRadiusMeters.toInt()}m)",
                                        style: TextStyle(fontSize: 11, color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                                      ),
                                    ] else if (_locationError != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        "Error: $_locationError",
                                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Time card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? SannidhiTheme.darkBg : SannidhiTheme.lightBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('hh:mm a').format(DateTime.now()),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Office Standard Start", style: TextStyle(fontSize: 11)),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: SannidhiTheme.teal.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "10:30 AM + 20m Grace",
                                          style: TextStyle(color: SannidhiTheme.teal, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Main Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: (_selectedMode == 'Present in Office' && !inRange) && !_isDemoMode
                                    ? null // Disabled if outside geofence and not in demo
                                    : _punchAttendance,
                                icon: const Icon(Icons.fingerprint_rounded),
                                label: Text(
                                  _selectedMode == 'Present in Office' && !inRange && !_isDemoMode
                                      ? "Punch Blocked (Outside Geofence)"
                                      : "Punch Attendance Now",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SannidhiTheme.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Helper Demo Setup Sidebox
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.settings_outlined, color: SannidhiTheme.teal, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Demo Controls',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Test present-in-office verification from anywhere in the world by centering the office geofence onto your current GPS coordinates.',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              value: _isDemoMode,
                              onChanged: (bool val) {
                                setState(() {
                                  _isDemoMode = val;
                                  if (val && _currentLat != null && _currentLon != null) {
                                    _officeLat = _currentLat!;
                                    _officeLon = _currentLon!;
                                  } else if (!val) {
                                    // Reset to actual office coordinates
                                    _officeLat = 13.0405;
                                    _officeLon = 80.2415;
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      val
                                          ? "Demo Mode enabled: Office coordinates moved to your current location."
                                          : "Demo Mode disabled: Office coordinates reset to T. Nagar, Chennai.",
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              title: const Text(
                                'Align Geofence to Me',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              contentPadding: EdgeInsets.zero,
                              activeColor: SannidhiTheme.teal,
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Standard Office Timing rules:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '• Up to 10:50 AM = Normal Present (Green)\n• After 10:50 AM = Late (Yellow)\n• Unpunched weekdays = Absent (Red)',
                              style: TextStyle(fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Attendance Logs Title
              Text(
                'Recent Attendance Records',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Records Table
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length > 8 ? 8 : records.length, // Show up to last 8 records
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(record.timestamp);
                    final timeStr = DateFormat('hh:mm:ss a').format(record.timestamp);
                    
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: record.mode == 'Work From Home'
                                ? Colors.blue.withOpacity(0.12)
                                : SannidhiTheme.teal.withOpacity(0.12),
                            child: Icon(
                              record.mode == 'Work From Home' ? Icons.home_work_outlined : Icons.apartment_rounded,
                              color: record.mode == 'Work From Home' ? Colors.blue : SannidhiTheme.teal,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(record.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: record.isLate 
                                      ? Colors.orange.withOpacity(0.12) 
                                      : Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  record.isLate ? "LATE" : "PRESENT",
                                  style: TextStyle(
                                    color: record.isLate ? Colors.orange : Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "$dateStr at $timeStr • ${record.mode}",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                            ),
                          ),
                          trailing: record.mode == 'Present in Office'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, color: Colors.green, size: 12),
                                      SizedBox(width: 4),
                                      Text("GPS Verified", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              : const Text("WFH Mode", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        ),
                        if (index < (records.length > 8 ? 7 : records.length - 1)) const Divider(height: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
