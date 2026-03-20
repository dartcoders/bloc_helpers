import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

part 'droppable.dart';
part 'restartable.dart';
part 'debounce.dart';

abstract final class BlocTransformers {
  static EventTransformer<Event> droppable<Event>() {
    return (events, mapper) {
      return events.transform(_ExhaustMapStreamTransformer(mapper));
    };
  }

  static EventTransformer<Event> restartable<Event>() {
    return (events, mapper) {
      return events.transform(_SwitchMapStreamTransformer(mapper));
    };
  }
  
  static EventTransformer<Event> debounce<Event>(Duration duration) {
    return (events, mapper) {
      return events.transform(_DebounceStreamTransformer(duration, mapper));
    };
  }
}
