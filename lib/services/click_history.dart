import 'dart:async';

class EventDescription {
  final int time;
  // Add other necessary fields

  EventDescription(this.time);
}

class ClickHistoryServiceDart {
  List<EventDescription> clickHistory = [];
  StreamController<int>? incremented;
  Timer? _timer;
  int timeFraction = 0;

  void startTimer([int interval = 100]) {
    _timer = Timer.periodic(Duration(milliseconds: interval), (Timer t) => addTime());
  }

  void addTime() {
    timeFraction += 1;
    if (incremented != null && !incremented!.isClosed) {
      emitNextSubject();
    }
  }

  void emitNextSubject() {
    incremented?.add(timeFraction);
  }

  void addEvent(EventDescription event) {
    int i = clickHistory.length;
    while (i > 0 && clickHistory[i - 1].time > event.time) {
      if (i < clickHistory.length) {
        clickHistory[i] = clickHistory[i - 1];
      }
      i--;
    }
    if (i < clickHistory.length) {
      clickHistory[i] = event;
    } else {
      clickHistory.add(event);
    }
  }

  void reinit() {
    clickHistory = [];
    stopTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    timeFraction = 0;
  }

  ClickHistoryServiceDart() {
    incremented = StreamController<int>.broadcast();
  }

  void dispose() {
    incremented?.close();
  }
}
