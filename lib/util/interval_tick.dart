import 'package:flutter/cupertino.dart';

class IntervalTick {
  final double timesPerSeconds;
  double _timeMax;
  double _baseNumber = 100.0;
  final VoidCallback tick;
  double _currentTime = 0;

  IntervalTick(this.timesPerSeconds, this.tick) {
    _timeMax = _baseNumber * timesPerSeconds;
  }

  void update(double dt) {
    _currentTime += dt * _timeMax;
    if (_currentTime >= _baseNumber) {
      tick();
      _currentTime = 0;
    }
  }
}
