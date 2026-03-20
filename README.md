# bloc_fx

A collection of helper classes, mixins, and event transformers for working with `flutter_bloc`.

## Features

- **Side Effects** - Emit one-time effects (navigation, snackbars, dialogs) from Blocs and Cubits without encoding them in state.
- **Event Transformers** - Droppable, restartable, and debounce transformers for Bloc events.
- **AppCubitHandler** - Base Cubit class with lifecycle hooks and safe emit.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  bloc_fx: ^1.0.0
```

## Usage

### Side Effects (Bloc)

Use `BlocEffectMixin` to emit one-time effects that don't belong in state:

```dart
// 1. Define your effect type
sealed class LoginEffect {}
class NavigateToHome extends LoginEffect {}
class ShowError extends LoginEffect {
  final String message;
  ShowError(this.message);
}

// 2. Mix into your Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState>
    with BlocEffectMixin<LoginEvent, LoginState, LoginEffect> {

  Future<void> _onSubmit(_Submit event, Emitter<LoginState> emit) async {
    emit(const LoginState.loading());
    try {
      await _loginUseCase(event.credentials);
      emitEffect(NavigateToHome());
    } catch (e) {
      emitEffect(ShowError(e.toString()));
    }
  }
}

// 3. Listen in the UI
BlocEffectListener<LoginBloc, LoginEffect>(
  listener: (context, effect) {
    switch (effect) {
      case NavigateToHome():
        Navigator.of(context).pushReplacementNamed('/home');
      case ShowError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  },
  child: const LoginPage(),
)
```

### Side Effects (Cubit)

```dart
class MyCubit extends Cubit<MyState>
    with CubitEffectMixin<MyState, MyEffect> {

  void doSomething() {
    emitEffect(MyEffect.showToast('Done'));
  }
}
```

### Event Transformers

Apply transformers to Bloc event handlers to control event processing:

```dart
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState.initial()) {
    // Debounce: wait for user to stop typing
    on<_QueryChanged>(
      _onQueryChanged,
      transformer: BlocTransformers.debounce(const Duration(milliseconds: 300)),
    );

    // Droppable: ignore new events while one is processing
    on<_LoadMore>(
      _onLoadMore,
      transformer: BlocTransformers.droppable(),
    );

    // Restartable: cancel previous and start new
    on<_Fetch>(
      _onFetch,
      transformer: BlocTransformers.restartable(),
    );
  }
}
```

| Transformer | Behavior |
|---|---|
| `droppable()` | Ignores new events while the current one is still processing |
| `restartable()` | Cancels the in-progress event and starts processing the new one |
| `debounce(duration)` | Waits for a pause in events before processing the latest one |

### AppCubitHandler

A base Cubit with `init()` / `dispose()` lifecycle and `safeEmit`:

```dart
class CounterCubit extends AppCubitHandler<int> {
  CounterCubit() : super(0);

  @override
  void init() {
    // Called after creation
  }

  @override
  void dispose() {
    // Called before close
  }

  void increment() => safeEmit(state + 1); // won't throw if closed
}
```
