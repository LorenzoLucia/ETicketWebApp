import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerTextField extends StatefulWidget {
  final Function(Duration)? onTimeChanged;
  final Duration? initialTime;
  final String? title;
  final DateTime? ticketEndTime;

  const TimePickerTextField({
    Key? key,
    this.onTimeChanged,
    this.initialTime,
    this.title,
    this.ticketEndTime,
  }) : super(key: key);

  @override
  State<TimePickerTextField> createState() => _TimePickerTextFieldState();
}

class _TimePickerTextFieldState extends State<TimePickerTextField> {
  Duration selectedTime = Duration(hours: 1);
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // selectedTime = widget.initialTime;
    _updateTextField();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration get _currentTimeAsDuration {
    DateTime now = DateTime.now();
    return Duration(hours: now.hour, minutes: now.minute);
  }

  DateTime _calculateTicketEndTime(Duration ticketDuration) {
    DateTime date = widget.ticketEndTime ?? DateTime.now();
    return date.add(ticketDuration);
  }

  Duration _calculateDifference(Duration pickedTime) {
    Duration currentTime = _currentTimeAsDuration;

    // Converti entrambe le duration in minuti per facilitare il calcolo
    int pickedMinutes = pickedTime.inMinutes;
    int currentMinutes = currentTime.inMinutes;

    int differenceMinutes = pickedMinutes - currentMinutes;

    if (differenceMinutes < 0) {
      differenceMinutes += 24 * 60;
    }

    return Duration(minutes: differenceMinutes);
  }

  String _formatTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  double _convertDurationToHours(Duration duration) {
    double hours = duration.inMinutes / 60;
    String oneDigitHours = hours.toStringAsFixed(2);
    return double.parse(oneDigitHours);
  }

  String _formatDate(DateTime date) {
    Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December",
    };

    String month = months[date.month]!;
    int day = date.day;
    int hour = date.hour;
    int minutes = date.minute;

    return '$day of $month at ${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _updateTextField() {
    if (selectedTime != null) {
      Duration difference = _calculateDifference(selectedTime!);
      _convertDurationToHours(difference);
      _controller.text = _formatTime(selectedTime!);
    } else {
      _controller.clear();
    }
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            String? title = widget.title;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ),
                        Text(
                          title ?? 'Select Ticket Duration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _updateTextField();
                            });
                            if (widget.onTimeChanged != null) {
                              widget.onTimeChanged!(selectedTime);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration display row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Ticket End Time: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _formatDate(_calculateTicketEndTime(selectedTime)),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Time Picker
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.hm,
                        initialTimerDuration: selectedTime,
                        onTimerDurationChanged: (Duration newTime) {
                          setModalState(() {
                            selectedTime = newTime;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 90,
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        onTap: _showTimePicker,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
