import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CalendarFormat _format = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TableCalendar(
          calendarFormat: _format,
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(1980, 01, 01),
          lastDay: DateTime.utc(2100, 12, 31),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        elevation: 0.0,
        shape: CircleBorder(),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: LinearBorder(),
              title: Text("Add event:"),
              content: TextField(
                autofocus: true,
                controller: _controller,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _controller.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Add")),
              ],
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30.0,
        ),
      ),
    );
  }
}
