import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppCubitHandler<T> extends Cubit<T> {
  AppCubitHandler(super.initialState);

  void init();

  void dispose() {}

  @override
  Future<void> close() {
    dispose();
    return super.close();
  }

  void safeEmit(T state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
