import 'dart:async';

import 'package:bloc_helpers/src/bloc_effect_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocEffectListener<B extends EffectEmitter<E>, E> extends StatefulWidget {
  final void Function(BuildContext context, E effect) listener;
  final Widget child;

  const BlocEffectListener({
    super.key,
    required this.listener,
    required this.child,
  });

  @override
  State<BlocEffectListener<B, E>> createState() =>
      _BlocEffectListenerState<B, E>();
}

class _BlocEffectListenerState<B extends EffectEmitter<E>, E>
    extends State<BlocEffectListener<B, E>> {
  StreamSubscription<E>? _sub;

  @override
  void didChangeDependencies() {
    _sub?.cancel();
    final bloc = context.read<B>();
    _sub = bloc.effectStream.listen((effect) {
      if (!mounted) return;
      widget.listener(context, effect);
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
