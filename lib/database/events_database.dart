import 'package:calendar_app/boxes.dart';

class EventsDatabase {
  Map<DateTime, List<String>> events = {};

  void loadData() {
    List allDynamicEvents = calendarBox.get("DAYEVENTS") ?? [];
    for (var dynamicEvent in allDynamicEvents) {
      events[dynamicEvent[0]] = dynamicEvent[1];
    }
  }

  void saveData() {
    List allDynamicEvents = [];
    for (var eventKey in events.keys) {
      allDynamicEvents
          .add([eventKey, events[eventKey]]);
    }
    calendarBox.put("DAYEVENTS", allDynamicEvents);
  }
}
