// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:polydiff/components/chronometer-limited.dart';
import 'package:polydiff/components/counter.dart';
import 'package:polydiff/components/play-area.dart';
import 'package:polydiff/pages/selecto-page.dart';
import 'package:polydiff/services/blinker.dart';
import 'package:polydiff/services/current-game.dart';
import 'package:polydiff/services/diference.dart';
import 'package:polydiff/services/difference-detection-service.dart'        ;
import 'package:polydiff/services/game-info.dart';
import 'package:polydiff/services/image-transfer.dart';
import 'package:polydiff/services/image-update.dart';
import 'package:polydiff/services/interfaces/gameStats.dart';
import 'package:polydiff/services/socket.dart';
// Autres imports nécessaires...

class GamePageClassic1v1 extends StatefulWidget {
  // final String link1;
  // final String link2;
  final Uint8List img1;
  Uint8List img2;
  List<Difference>? diff;

  GamePageClassic1v1(
      {Key? key, required this.img1, required this.img2, this.diff})
      : super(key: key);

  @override
  _GamePageClassic1v1State createState() => _GamePageClassic1v1State();
}

class _GamePageClassic1v1State extends State<GamePageClassic1v1> {
  final GlobalKey<CountdownState> _chronometerKey =
      GlobalKey<CountdownState>();

  // Services
  final ImageTransferService imageTransfer = ImageTransferService();
  final GameInfoService gameInfo = GameInfoService();
  final DifferencesDetectionService differencesDetectionService =
      DifferencesDetectionService();
  final ImageUpdateService imageUpdateService = ImageUpdateService();
  final BlinkerService blinker = BlinkerService();
  // final CheatModeService cheatModeService = CheatModeService();
  final CurrentGameService currentGameService = CurrentGameService();
  // final GameHistoryService gameHistoryService = GameHistoryService();
  // final ReplayService replayService = ReplayService();

  late StreamSubscription<List<Difference>?> _foundDiffSubscription;
  late StreamSubscription<List<int>> _countSubscription;
  late StreamSubscription<List<Difference>?>? _diffSubscription;
  late StreamSubscription<List<String>> _playerNamesSubscription;
  late StreamSubscription<List<bool>> _endGameSubscription;

  //use global key for the 4 counters
  final GlobalKey<CounterState> counter1Key = GlobalKey();
  final GlobalKey<CounterState> counter2Key = GlobalKey();
  final GlobalKey<CounterState> counter3Key = GlobalKey();
  final GlobalKey<CounterState> counter4Key = GlobalKey();

  // int _foundDifferencesCount = 0;
  String _playerName = '';
  // Variables d'état
  String username = "";
  String username2 = "";
  String username3 = "";
  String username4 = "";
  String link1 = "";
  String link2 = "";
  bool wantToQuit = false;
  bool gameEnded = false;
  List<Difference>? diff;


  int _counter1 = 0;
  int _counter2 = 0;
  int _counter3 = 0;
  int _counter4 = 0;

  Uint8List? _updatedImg2;

  void onContinue() {
      // TODO: OBSERVER FOR CLASSIC
      SocketService.socket.emit('leaveGameMulti', {  'observer': false ,'observerName': ''});
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir quitter ?'),
          actions: [
            TextButton(
              onPressed: () {
                GameStats gameStats = GameStats(
                  winner: currentGameService.winner,
                  loser: currentGameService.winner == username
                      ? username2
                      : username,
                  winnerDifferencesFound: currentGameService.winner == username
                      ? _counter1
                      : _counter2,
                  loserDifferencesFound: currentGameService.winner == username
                      ? _counter2
                      : _counter1,
                  gameTime: _chronometerKey.currentState?.seconds ?? 0,
                );
                onContinue();
                currentGameService.gameEnded(true, gameStats);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SelectoPageWidget(),
                ));
              },
              child: Text('Oui'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Non'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    currentGameService.resetCounts();
    super.initState();
    initialiseGame();

    // Listen to differences found and update UI

    _playerNamesSubscription =
        gameInfo.playerNamesController.stream.listen((names) {
      // if (names.isNotEmpty) {
      String tempUsername3 = '';
      String tempUsername4 = '';
      print('$names names');
      final tempUsername = names[0];
      print(tempUsername);
      final tempUsername2 = names[1];
      if (names.length > 2) {
        tempUsername3 = names[2];
      } else {
        username3 = '';
      }
      if (names.length > 3) {
        tempUsername4 = names[3];
      } else {
        username4 = '';
      }
      // }
      if (mounted) {
        setState(() {
          username = tempUsername;
          username2 = tempUsername2;
          username3 = tempUsername3;
          username4 = tempUsername4;
        });
      }
    });

    _foundDiffSubscription =
        differencesDetectionService.foundStream.listen((foundDiffs) async {
      print('Found differences: ${foundDiffs}');
      final updatedImage = await imageUpdateService.updateImage(
          foundDiffs, widget.img1, widget.img2);
      if (mounted) {
        setState(() {
          widget.img2 = updatedImage;
        });
      }
    });

    _diffSubscription =
        differencesDetectionService.differenceStream.listen((diffs) {
      print('Differences: ${diffs}');
      if (mounted) {
        setState(() {
          widget.diff = diffs;
        });
      }
    });

    // Listen to player counts updates and update UI
    _countSubscription =
        currentGameService.playerCountsStream.listen((playerCounts) {
      if (mounted) {
        setState(() {
          _counter1 = playerCounts.isNotEmpty ? playerCounts[0] : 0;
          _counter2 = playerCounts.length > 1 ? playerCounts[1] : 0;
          _counter3 = playerCounts.length > 2 ? playerCounts[2] : 0;
          _counter4 = playerCounts.length > 3 ? playerCounts[3] : 0;
        });
      }
    });

    _foundDiffSubscription = currentGameService.diffArrayStream.listen((diffArray) {
      setState(() {
        differencesDetectionService
            .setDifference(widget.diff as List<Difference>?);
        imageUpdateService.updateImage(diffArray, widget.img1, widget.img2);
      });
    });

    _endGameSubscription =  currentGameService.endGameStream.listen((endGame) {
      if (mounted) {
        setState(() {
          gameEnded = endGame[0];
          if (gameEnded) {
            _chronometerKey.currentState?.stopTimer();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Fin du jeu'),
                  content:
                      Text('Le vainqueur est : ' + currentGameService.winner),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Retour à la page de sélection'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SelectoPageWidget(),
                        ));
                      },
                    ),
                  ],
                );
              },
            );
          }
        });
      }
    });
  }

  Future<ui.Image> _convertToUiImage(Uint8List imgBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imgBytes, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void initialiseGame() {}

  @override
  void dispose() {
    _chronometerKey.currentState?.stopTimer();
    currentGameService.resetCounts();
    _foundDiffSubscription.cancel();
    _countSubscription.cancel();
    _endGameSubscription.cancel();
    _playerNamesSubscription.cancel();
    _diffSubscription?.cancel();
    _counter1 = 0;
    _counter2 = 0;
    _counter3 = 0;
    _counter4 = 0;
    _playerNamesSubscription.cancel();
    _diffSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Counter(name: username, counter: _counter1),
                        Counter(
                            name: username2,
                            counter:
                                _counter2), // Import the correct file for the Difference class
                        PlayAreaWidget(
                            img: widget.img1,
                            diff: widget.diff as List<Difference>?),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // Placeholder for logo
                      SizedBox(height: 60), // Adjust size accordingly
                      // Placeholder for GameInfo (You might need to create or adjust a widget for GameInfo)
                      SizedBox(height: 20),
                      Countdown(key: _chronometerKey),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Counter(name: username3, counter: _counter3),
                        Counter(name: username4, counter: _counter4),
                        PlayAreaWidget(
                            img: widget.img2,
                            diff: widget.diff as List<
                                Difference>?), // Import the correct file for the Difference class
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _showConfirmationDialog,
              child: Text('Abandonner'),
            ),
          ],
        ),
      ),
    );
  }
}