class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  int numberFruits = 0;
  int life = 0;
  String playerName = '';
  int point = 0;
  int pixel = 100;

  DateTime? startTime; 

  GlobalState._internal();

  factory GlobalState() {
    return _instance;
  }

  void resetPoint() {
    point = 0;
  }

  void resetPixel() {
    pixel = 100;
  }

  void resetLife() {
    life = 3;
  }

  void minusLife() {
    life--;
  }

  void start() {
    startTime = DateTime.now();
  }

  Duration getElapsedTime() {
    if (startTime != null) {
      return DateTime.now().difference(startTime!);
    } else {
      return Duration.zero; 
    }
  }
}
