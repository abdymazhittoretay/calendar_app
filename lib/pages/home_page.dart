import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {};

  late final ValueNotifier<List<String>> _selectedEvents;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEvents(_selectedDay!));
    super.initState();
  }

  List<String> _getEvents(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              calendarFormat: _format,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(1980, 01, 01),
              lastDay: DateTime.utc(2100, 12, 31),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents.value = _getEvents(_selectedDay!);
                  });
                }
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEvents,
            ),
            Expanded(
                child: ValueListenableBuilder(
              valueListenable: _selectedEvents,
              builder: (context, value, child) {
                return value.isNotEmpty
                    ? ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                                top: 10.0, left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: ListTile(
                              title: Text(value[index]),
                              trailing: IconButton(
                                  onPressed: () {
                                    _events.remove(_selectedDay);
                                    _selectedEvents.value =
                                        _getEvents(_selectedDay!);
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  )),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "No events on this day.",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      );
              },
            )),
          ],
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
                      if (_controller.text.isNotEmpty) {
                        final List<String> eventList =
                            _getEvents(_selectedDay!);
                        eventList.insert(0, _controller.text);
                        _events.addAll({_selectedDay!: eventList});
                        _selectedEvents.value = _getEvents(_selectedDay!);
                        setState(() {});
                      }
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
