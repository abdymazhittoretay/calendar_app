import 'package:calendar_app/database/events_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final ValueNotifier<List<String>> _selectedEvents;

  final TextEditingController _controller = TextEditingController();

  final EventsDatabase db = EventsDatabase();

  @override
  void initState() {
    db.loadData();
    _selectedDay =
        DateTime.utc(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _selectedEvents = ValueNotifier(_getEvents(_selectedDay!));
    super.initState();
  }

  List<String> _getEvents(DateTime day) {
    return db.events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.75,
                    ),
                    color: Colors.white),
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple[200],
                ),
              ),
              calendarFormat: _format,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(1980, 01, 01),
              lastDay: DateTime.utc(2100, 12, 31),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents.value = _getEvents(_selectedDay!);
                  });
                }
              },
              onFormatChanged: (format) {
                if (_format != format) {
                  setState(() {
                    _format = format;
                  });
                }
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _getEvents(day);
              },
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
                                    db.events[_selectedDay]!.removeAt(index);
                                    db.saveData();
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
                        db.events.addAll({_selectedDay!: eventList});
                        db.saveData();
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
