import 'dart:async';

import 'package:bloc_fx/src/bloc_effect_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin CubitEffectMixin<State, Effect> on Cubit<State>
    implements EffectEmitter<Effect> {
  final _effectController = StreamController<Effect>.broadcast();

  @override
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
