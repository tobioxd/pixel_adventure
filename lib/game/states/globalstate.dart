class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  int numberFruits = 0;
  int life = 0;
  String playerName = '';

  factory GlobalState() {
    return _instance;
  }

  void resetLife(){
    life = 3;
  }

  void minusLife(){
    life--;
  }

  GlobalState._internal();
}
