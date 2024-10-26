class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  int numberFruits = 0;
  int life = 0;

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();
}
