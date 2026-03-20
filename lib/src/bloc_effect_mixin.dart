import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract interface class EffectEmitter<E> {
  Stream<E> get effectStream;
}

mixin BlocEffectMixin<Event, State, Effect> on Bloc<Event, State> implements EffectEmitter<Effect> {
  final _effectController = StreamController<Effect>.broadcast();

  @override
  @visibleForTesting
  Stream<Effect> get effectStream => _effectController.stream;

  @protected
  void emitEffect(Effect effect) {
    if (!_effectController.isClosed) {
      _effectController.add(effect);
    }
  }

  @override
  Future<void> close() {
    _effectController.close();
    return super.close();
  }
}
