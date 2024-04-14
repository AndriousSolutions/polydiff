import 'dart:async';

import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {

  const Countdown({
    Key? key,
  }) : super(key: key);
  @override
  CountdownState createState() => CountdownState();
}

class CountdownState extends State<Countdown> {
  Timer? _timer;
  int _start = 120;

  // getter for minuts
  int get minutes => _start ~/ 60;
  //getter for seconds
  int get seconds => _start % 60;

  int get remainingTime => _start;

  void startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void addTime(int time) {
    _start += time;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}",
        style: TextStyle(fontSize: 48),
      ),
    );
  }

  void startCountDownFrom(int seconds) {
    _timer?.cancel();
    _start = seconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    // _start = 0;
  }
}