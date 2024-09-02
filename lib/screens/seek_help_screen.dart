import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class SeekHelpScreen extends StatefulWidget {
  final CalendarFormat calendarFormat;

  const SeekHelpScreen({super.key, this.calendarFormat = CalendarFormat.month});

  @override
  SeekHelpScreenState createState() => SeekHelpScreenState();
}

class SeekHelpScreenState extends State<SeekHelpScreen> {
  late CalendarFormat _calendarFormat;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;
  DateTime _selectedTime = DateTime(2024, 1, 1, 8, 0);

  @override
  void initState() {
    super.initState();
    _calendarFormat = widget.calendarFormat;
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: _selectedTime,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _selectedTime = newDateTime;
              });
            },
            use24hFormat: false,
            minuteInterval: 1,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showCalendar) ...[
                const Text(
                  'Talk to a professional about your mental health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No Schedule yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCalendar = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4594),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book an Appointment',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              if (_showCalendar) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back,
                          size: 16, color: Color(0xFF1A4594)),
                      label: const Text('Back',
                          style: TextStyle(color: Color(0xFF1A4594))),
                      onPressed: () {
                        setState(() {
                          _showCalendar = false;
                          _selectedDay = null;
                        });
                      },
                    ),
                    const Center(
                      child: Text(
                        'Book an Appointment',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay:
                              DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          enabledDayPredicate: (day) {
                            return day.weekday < 6 &&
                                day.isAfter(DateTime.now()
                                    .subtract(const Duration(days: 1)));
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: true,
                            weekendTextStyle: TextStyle(color: Colors.red),
                            holidayTextStyle: TextStyle(color: Colors.red),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Time: '),
                        TextButton(
                          onPressed: _showTimePicker,
                          child: Text(
                            _formatTime(_selectedTime),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1A4594),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Handle submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4594),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
