part of 'bloc_transformers.dart';

class _DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _DebounceStreamTransformer(this.duration, this.mapper);

  final Duration duration;
  final EventMapper<T> mapper;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    Timer? debounceTimer;

    StreamSubscription<T>? mappedSubscription;

    final controller = StreamController<T>(
      onCancel: () async {
        debounceTimer?.cancel();
        await mappedSubscription?.cancel();
        await subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      (event) {
        debounceTimer?.cancel();

        debounceTimer = Timer(duration, () {
          final mappedStream = mapper(event);

          mappedSubscription?.cancel();
          mappedSubscription = mappedStream.listen(
            controller.add,
            onError: controller.addError,
          );
        });
      },
      onError: controller.addError,
      onDone: () {
        debounceTimer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }
}
