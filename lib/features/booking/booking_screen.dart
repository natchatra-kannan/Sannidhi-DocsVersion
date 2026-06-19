import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/mock_data.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<MeetingBooking> _bookings = List.from(MockData.initialBookings);
  String _selectedRoomId = 'room-helipad';
  
  // Form values
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Check if booking overlaps with existing bookings
  bool _hasConflict(String roomId, DateTime start, DateTime end) {
    for (var booking in _bookings) {
      if (booking.roomId == roomId) {
        // Overlap formula: StartA < EndB AND EndA > StartB
        if (start.isBefore(booking.endTime) && end.isAfter(booking.startTime)) {
          return true;
        }
      }
    }
    return false;
  }

  void _bookRoom() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final end = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      // Validation 1: End Time after Start Time
      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        setState(() {
          _errorMessage = 'Error: End time must be after the start time.';
        });
        return;
      }

      // Validation 2: Conflict check
      if (_hasConflict(_selectedRoomId, start, end)) {
        setState(() {
          _errorMessage = 'Conflict Detected: This room is already booked during the selected timeslot.';
        });
        return;
      }

      // Create booking
      final newBooking = MeetingBooking(
        id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
        roomId: _selectedRoomId,
        bookedBy: MockData.currentUser.fullName,
        title: _titleController.text,
        startTime: start,
        endTime: end,
      );

      setState(() {
        _bookings.add(newBooking);
        _successMessage = 'Booking confirmed successfully!';
        _titleController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final currentRoom = MockData.meetingRooms.firstWhere((r) => r.id == _selectedRoomId);
    final roomBookings = _bookings.where((b) => b.roomId == _selectedRoomId).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

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
                'Meeting Room Booking',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Reserve dynamic spaces with automated conflict prevention rules',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Timeline and Rooms List
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rooms Grid
                    Text(
                      'Select a Meeting Room',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: MockData.meetingRooms.length,
                      itemBuilder: (context, index) {
                        final room = MockData.meetingRooms[index];
                        final isSelected = room.id == _selectedRoomId;
                        return Card(
                          color: isSelected ? SannidhiTheme.teal.withOpacity(0.15) : null,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRoomId = room.id;
                                _errorMessage = null;
                                _successMessage = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    room.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected ? SannidhiTheme.teal : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Capacity: ${room.capacity} seats', style: const TextStyle(fontSize: 11)),
                                  Text(room.location, style: const TextStyle(fontSize: 11, color: SannidhiTheme.textMutedDark)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Daily Timeline Widget
                    Text(
                      'Today\'s Timeline (${currentRoom.name})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (roomBookings.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No bookings for this room today.',
                              style: TextStyle(color: isDark ? SannidhiTheme.textMutedLight : SannidhiTheme.textMutedDark),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: roomBookings.length,
                        itemBuilder: (context, index) {
                          final booking = roomBookings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.schedule, color: SannidhiTheme.teal),
                              title: Text(booking.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(
                                'Booked by ${booking.bookedBy}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                '${DateFormat('hh:mm a').format(booking.startTime)} - ${DateFormat('hh:mm a').format(booking.endTime)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: SannidhiTheme.iceBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Create Booking Side Form
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.add_box_rounded, color: SannidhiTheme.teal),
                              SizedBox(width: 8),
                              Text('Create Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const Divider(height: 24),
                          
                          // Room indicator
                          Text(
                            'Room: ${currentRoom.name}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          // Meeting title
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Meeting Title',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Please enter meeting title';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date picker
                          ListTile(
                            leading: const Icon(Icons.calendar_today_rounded, color: SannidhiTheme.teal),
                            title: const Text('Date', style: TextStyle(fontSize: 12)),
                            subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                          ),
                          const Divider(),

                          // Start Time
                          ListTile(
                            leading: const Icon(Icons.access_time_rounded, color: SannidhiTheme.iceBlue),
                            title: const Text('Start Time', style: TextStyle(fontSize: 12)),
                            subtitle: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );
                              if (picked != null) {
                                setState(() => _startTime = picked);
                              }
                            },
                          ),
                          const Divider(),

                          // End Time
                          ListTile(
                            leading: const Icon(Icons.access_time_filled_rounded, color: SannidhiTheme.iceBlue),
                            title: const Text('End Time', style: TextStyle(fontSize: 12)),
                            subtitle: Text(_endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                              );
                              if (picked != null) {
                                setState(() => _endTime = picked);
                              }
                            },
                          ),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Error/Success indicators
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          if (_successMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: SannidhiTheme.teal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: SannidhiTheme.teal.withOpacity(0.3)),
                              ),
                              child: Text(
                                _successMessage!,
                                style: const TextStyle(color: SannidhiTheme.teal, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),

                          // Submit Button
                          ElevatedButton(
                            onPressed: _bookRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SannidhiTheme.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
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
