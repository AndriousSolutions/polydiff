import 'dart:async';

import 'package:polydiff/services/interfaces/game-consts-interface.dart';

import 'game-card-template.dart';
import 'socket.dart';

class GameInfoService {
  // final SocketService socketService;
  String username = '';
  String username2 = '';
  String username3 = '';
  String username4 = '';
  int numberOfPlayers = 0;
  String? gameName = '';
  String? gameCardId = '';
  String? difficulty = '';
  int? nDiff = 0;
  bool? isSolo = true;
  bool isLeader = false;
  int? time = 0;
  List<String> coopUsername = [];
  List<GameCardTemplate> gameCards = [];
  List<String> playerNames = [];
  int nGameCards = 0;
  List<int> cardOrder = [];
  String coopId = '';

  int initialTime = 120;
  int penalty = 0;
  int timeWon = 0;
  int timeAddedDifference = 0;
  bool cheatMode = false;

  final StreamController<int> playerNumber = StreamController<int>.broadcast();
  final StreamController<List<String>> playerNamesController =
      StreamController<List<String>>.broadcast();
  final StreamController<int> initialTimeGameController =
      StreamController<int>.broadcast();
  final StreamController<int> penaltyGameController =
      StreamController<int>.broadcast();
  final StreamController<int> timeWonGameController =
      StreamController<int>.broadcast();
  final StreamController<bool> cheatModeGameController =
      StreamController<bool>.broadcast();
  final StreamController<int> maxTimeGameController =
      StreamController<int>.broadcast();

  GameInfoService._internal() {
    print("GameInfoService internal constructor");
    initialize();
  }

  static final GameInfoService _instance = GameInfoService._internal();

  factory GameInfoService() => _instance;

  Future<void> initialize() async {
    print("GameInfoService initialize");
    SocketService.socket.on("PlayerNumber", (res) {
      if (res != -1) {
        playerNumber.add(res);
      }
    });

    SocketService.socket.on('Players', (res) {
      print('PlayerNames: $res');
      if (res != null) {
        List<String> stringList =
            List<String>.from(res.map((item) => item.toString()));
        playerNames = stringList;
        playerNamesController.add(stringList);
        print('Updated player names: $playerNames');
      }
    });

    SocketService.socket.on('Constants', (data) {
      if (data != null) {
        final constants = Constants.fromJson(data);
        initialTimeGameController.add(constants.initialTime);
        penaltyGameController.add(constants.penalty);
        timeWonGameController.add(constants.timeWon);
        cheatModeGameController.add(constants.cheatMode);
        // maxTimeGameController.add(constants.maxTime); // add this to the constant interface
      }
    });
    SocketService.socket.on('launchLobby', (data) {
      if (data != null) {
        final constants = Constants.fromJson(data);
        initialTimeGameController.add(constants.initialTime);
        penaltyGameController.add(constants.penalty);
        timeWonGameController.add(constants.timeWon);
        cheatModeGameController.add(constants.cheatMode);
      }
    });
  }

  void dispose() {
    playerNamesController.close();
    SocketService.socket.off('Players');
    SocketService.socket.off('PlayerNumber');
    SocketService.socket.off('Constants');
    SocketService.socket.off('launchLobby');
  }
}
