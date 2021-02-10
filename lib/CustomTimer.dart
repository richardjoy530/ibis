import 'dart:async';

class IbisTimer {
  Timer _timer;
  Duration _duration;
  DateTime startTime;
  void Function(Timer) _callback;

  IbisTimer(Duration duration, void Function(Timer) callback) {
    _callback = callback;
    _duration = duration;
    startTime = DateTime.now();
    _timer = Timer.periodic(duration, wrapperFunction);
  }

  void cancel() {
    _timer.cancel();
  }

  bool get isActive => _timer.isActive;

  int get tick {
    Duration tempDuration = DateTime.now().difference(startTime);
    double multiplier = tempDuration.inMilliseconds / _duration.inMilliseconds;
    return multiplier.toInt();
  }

  void wrapperFunction(Timer timer) {
    Duration tempDuration = DateTime.now().difference(startTime);
    double multiplier = tempDuration.inMilliseconds / _duration.inMilliseconds;
    for (int i = 0; i < multiplier; i++)
      _callback.call(timer);

  }

}
