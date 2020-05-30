import 'dart:async';

class DisplayListBloc {
  StreamController<Map<String, bool>> _controller =
      StreamController<Map<String, bool>>();
  Stream<Map<String, bool>> get stream => _controller.stream;

  StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  void dispose() {
    _isLoadingController.close();
    _controller.close();
  }

  void setIsLoading(bool isLoading) => _isLoadingController.add(isLoading);
  void setStreamData(Map<String, bool> data) => _controller.add(data);
}
