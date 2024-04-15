// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polydiff/components/chronometer_limited.dart';
import 'package:polydiff/components/play_area.dart';
import 'package:polydiff/components/popup_limited_end.dart';
import 'package:polydiff/pages/main_page.dart';
import 'package:polydiff/services/card_queue.dart';
import 'package:polydiff/services/communication.dart';
import 'package:polydiff/services/current_game.dart';
import 'package:polydiff/services/diference.dart';
import 'package:polydiff/services/difference_detection_service.dart';
import 'package:polydiff/services/game_info.dart';
import 'package:polydiff/services/interfaces/gameStats.dart';
import 'package:polydiff/services/socket.dart';
import 'package:polydiff/services/user.dart';

class LimitedTimePage extends StatefulWidget {
  @override
  _LimitedTimePageState createState() => _LimitedTimePageState();
}

class _LimitedTimePageState extends State<LimitedTimePage> {
  final GameInfoService gameInfo = GameInfoService();
  final DifferencesDetectionService differencesDetectionService =
      DifferencesDetectionService();
  final CommunicationService communicationService = CommunicationService();
  final CurrentGameService currentGame = CurrentGameService();
  late CardQueueService cardQueueService = CardQueueService();
  late AudioPlayer audioPlayer = AudioPlayer();

  late Timer _timer;

  late String username;
  String username2 = '';
  String username3 = '';
  String username4 = '';

  String winner = '';
  late int playerNumber;
  late List<String> playerNames;

  int _counter1 = 0;
  int _counter2 = 0;
  int _counter3 = 0;
  int _counter4 = 0;

  int tempsDebut = 120;
  int timeWon = 0;
  int maxTime = 120;
  bool cheatModeValid = false;

  final GlobalKey<CountdownState> _chronometerKey = GlobalKey<CountdownState>();

  bool leader = false;
  bool boolStartImage = false;
  bool gameEnded = false;
  String endingMessage = '';

  late Uint8List img1 = Uint8List(0);
  late Uint8List img2 = Uint8List(0);

  late StreamSubscription<Uint8List> _leftImageSubscription;
  late StreamSubscription<Uint8List> _rightImageSubscription;
  late StreamSubscription<List<Difference>> _differencesSubscription;
  late StreamSubscription<List<String>> _playerNamesSubscription;
  late StreamSubscription<int> _playerNumberSubsciption;
  late StreamSubscription<List<int>> _countSubscription;
  late StreamSubscription<String> _winnerSubscription;
  late StreamSubscription<List<bool>> _endGameSubscription;

  late StreamSubscription<int> _initialTimeGameSubscription;
  late StreamSubscription<int> _penaltyGameSubscription;
  late StreamSubscription<int> _timeWonGameSubscription;
  late StreamSubscription<bool> _cheatModeGameSubscription;
  late StreamSubscription<int> _maxTimeGameSubscription;

  late List<Difference> diff = <Difference>[];
  @override
  void initState() {
    super.initState();

    username = User.username;

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      // print('Timer: ${_chronometerKey.currentState?.remainingTime}');
      if (_chronometerKey.currentState?.remainingTime == 0) {
        endGame(false);
        _showEndingPopUp();
        t.cancel(); // Cancel the timer once the game has ended
      }
    });

    //Update Timer
    SocketService.socket.on('updateTimer', (data) {
      print('updateTimer');
      if (data != null) {
        print('data: $data');
        _chronometerKey.currentState?.stopTimer();
        _chronometerKey.currentState?.startCountDownFrom(data);
      }
    });

    SocketService.socket.on('requestTimerRedirection', (data) {
      print('requestTimerRedirection');
      if (data != null) {
        print('data: $data');
        final time = _chronometerKey.currentState?.remainingTime;
        SocketService.socket.emit('timerRedirection', {'timer': time});
      }
    });

    _endGameSubscription = currentGame.endGameStream.listen((endProps) {
      if (endProps[0]) {
        endGame(endProps[1]);
        _showEndingPopUp();
      }
    });

    _playerNumberSubsciption = gameInfo.playerNumber.stream.listen((number) {
      playerNumber = number;
      if (playerNumber == 0) {
        print('Player number: $playerNumber');
        leader = true;
        if (!boolStartImage) {
          cardQueueService.getNext();
          boolStartImage = true;
        }
      }
      print('Player number: $playerNumber');
      print('Leader: $leader');
    });

    _playerNamesSubscription =
        gameInfo.playerNamesController.stream.listen((names) {
      if (names.isNotEmpty) {
        if (mounted) {
          print('Player names: $names');
          if (names.isNotEmpty) {
            setState(() {
              username = names[0];
              username2 = names.length > 1 ? names[1] : '';
              username3 = names.length > 2 ? names[2] : '';
              username4 = names.length > 3 ? names[3] : '';
              print('username2: $username2');
            });
          }
        }
      }
    });

    currentGame.resetCounts();
    _countSubscription = currentGame.playerCountsStream.listen((playerCounts) {
      final arrayCounter = [_counter1, _counter2, _counter3, _counter4];
      if (mounted) {
        // setState(() {
        //   _counter1 = playerCounts.isNotEmpty ? playerCounts[0] : 0;
        //   _counter2 = playerCounts.length > 1 ? playerCounts[1] : 0;
        //   _counter3 = playerCounts.isNotEmpty ? playerCounts[2] : 0;
        //   _counter4 = playerCounts.length > 1 ? playerCounts[3] : 0;
        // });
      }
      if (arrayCounter[playerNumber] != playerCounts[playerNumber]) {
        if (_chronometerKey.currentState!.minutes * 60 +
                _chronometerKey.currentState!.seconds +
                10 >
            maxTime) {
          print('Temps max atteint');
          _chronometerKey.currentState?.startCountDownFrom(maxTime);
        } else {
          print('time added');
          _chronometerKey.currentState?.addTime(timeWon);
        }
      }
    });

    _winnerSubscription = currentGame.winnerStream.listen((winnerName) {
      if (winnerName != '') {
        print('Winner: $winnerName');
        if (mounted) {
          setState(() {
            winner = winnerName;
          });
        }
      }
    });
    cardQueueSetup();
    gettingMissingValues();
    emittingMissingValues();
  }

  void cardQueueSetup() {
    if (leader) {
      print('leader:  $leader');
      cardQueueService.getNext();
      boolStartImage = true;
    }

    _leftImageSubscription = cardQueueService.leftImage.stream.listen((x) {
      print('left image url subscription');
      final image1 = x;
      if (mounted) {
        if (image1.isNotEmpty) {
          setState(() {
            img1 = image1;
          });
        }
      }
    });

    _rightImageSubscription = cardQueueService.rightImage.stream.listen((x) {
      final image2 = x;
      if (mounted) {
        if (image2.isNotEmpty) {
          setState(() {
            img2 = image2;
          });
        }
      }
    });

    _differencesSubscription = cardQueueService.differences.stream.listen((x) {
      if (mounted) {
        print('differences in limitedTimePage: $x');
        if (x.isNotEmpty) {
          setState(() {
            diff = x;
            differencesDetectionService.setDifference(diff);
          });
        }
      }
    });

    differencesDetectionService.foundStream.listen((event) {
      print('foundStream');
      if (leader) {
        cardQueueService.getNext();
      }
    });

    currentGame.endGameStream.listen((endProps) {
      print('endGameStream');
      if (endProps[0]) {
        print('endGame');
        // endGame(endProps[1]);
        // _showEndingPopUp();
      }
    });

    _initialTimeGameSubscription =
        gameInfo.initialTimeGameController.stream.listen((time) {
      print('initialTimeGameController');
      if (time != 0) {
        if (mounted) {
          setState(() {
            tempsDebut = time;
          });
        }
      }
      _chronometerKey.currentState?.startCountDownFrom(time);
    });

    _maxTimeGameSubscription =
        gameInfo.maxTimeGameController.stream.listen((time) {
      print('maxTimeGameController');
      if (time != 0) {
        if (mounted) {
          setState(() {
            maxTime = time;
          });
        }
      }
    });

    _timeWonGameSubscription =
        gameInfo.timeWonGameController.stream.listen((time) {
      print('timeWonGameController');
      if (time != 0) {
        if (mounted) {
          setState(() {
            timeWon = time;
          });
        }
      }
    });
  }

  void emittingMissingValues() {
    print('emittingMissingValues');
    SocketService.socket.emit('getNamesAndroid', null);
    SocketService.socket.emit('getConstantsAndroid', null);
  }

  void gettingMissingValues() {
    SocketService.socket.on(
        'returnNamesAndroid',
        (data) => {
              print('returnNamesAndroid: $data'),
              if (data != null)
                {
                  if (data['PlayersNames'].length > 0 && mounted)
                    {
                      setState(() {
                        username = data['PlayersNames'][0];
                        username2 =
                            data.length >= 1 ? data['PlayersNames'][1] : '';
                        username3 =
                            data.length >= 2 ? data['PlayersNames'][2] : '';
                        username4 =
                            data.length >= 3 ? data['PlayersNames'][3] : '';

                        print(
                            'username1: $username username2: $username2, username3: $username3, username4: $username4');
                      })
                    }
                }
            });

    SocketService.socket.on(
        'returnAndroidConstants',
        (data) => {
              if (data != null)
                {
                  print('returnConstantsAndroid: $data'),
                  if (data.length > 0 && mounted)
                    {
                      setState(() {
                        tempsDebut = data[0];
                        timeWon = data[1];
                        maxTime = data[2];
                        cheatModeValid = data[3];
                        _chronometerKey.currentState
                            ?.startCountDownFrom(tempsDebut);
                      })
                    }
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    gettingMissingValues();
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
                        Column(
                          children: [
                            Text('Nom du joueur 1: $username'),
                            Text('Nombre de différences trouvées: $_counter1'),
                            // names.length > 1
                            Text('Nom du joueur 2: $username2'),
                            // : Text(''),
                            Text('Nombre de différences trouvées: $_counter2'),
                          ],
                        ),
                        PlayAreaWidget(
                            img: img1, diff: diff as List<Difference>?),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // Placeholder for logo
                      SizedBox(height: 10), // Adjust size accordingly
                      // Placeholder for GameInfo (You might need to create or adjust a widget for GameInfo)
                      // Adjust size accordingly
                      Countdown(
                        key: _chronometerKey,
                      )
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        StreamBuilder<List<String>>(
                          stream: gameInfo.playerNamesController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final names = snapshot.data!;
                              return Column(
                                children: [
                                  names.length > 2
                                      ? Text('Nom du joueur 3: ${names[2]}')
                                      : Text(''),
                                  Text(
                                      'Nombre de différences trouvées: $_counter3'),
                                  names.length > 3
                                      ? Text('Nom du joueur 3: ${names[3]}')
                                      : Text(''),
                                  Text(
                                      'Nombre de différences trouvées: $_counter3'),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Text(''),
                                ],
                              ); // Ou un autre widget pour l'état de chargement
                            }
                          },
                        ),
                        PlayAreaWidget(
                            img: img2, diff: diff as List<Difference>?),
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

  // End Game
  void endGame(bool quit) async {
    print('here in endGame');
    gameEnded = true;
    final message = (_chronometerKey.currentState?.remainingTime == 0)
        ? 'Temps écoulé!'
        : 'Bravo vous avez complété toutes les fiches!';
    print('message: $message');
    setState(() {
      endingMessage = message;
    });
    SocketService.socket.emit('leaveGame', null);
    _chronometerKey.currentState?.stopTimer();
  }

  void playErrorSound() async {
    print('playErrorSound');
    final String audioPath = User.specialErrorSoundUsed
        ? 'special-audios/fail-sound.mp3'
        : 'audios/error.mp3';
    await audioPlayer.play(AssetSource(audioPath));
  }

  void _showEndingPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopupEndingDialog(message: endingMessage);
      },
    );
  }

  @override
  void dispose() {
    cardQueueService.stopListening();
    gameInfo.dispose();
    currentGame.dispose();
    _differencesSubscription.cancel();
    _leftImageSubscription.cancel();
    _rightImageSubscription.cancel();
    _playerNamesSubscription.cancel();
    _countSubscription.cancel();
    _playerNumberSubsciption.cancel();
    _winnerSubscription.cancel();
    _timer.cancel();
    _endGameSubscription.cancel();
    _initialTimeGameSubscription.cancel();
    _penaltyGameSubscription.cancel();
    _timeWonGameSubscription.cancel();
    _cheatModeGameSubscription.cancel();
    _maxTimeGameSubscription.cancel();
    SocketService.socket.off('updateTimer');
    SocketService.socket.off('requestTimerRedirection');
    super.dispose();
  }

  // Confirnation Dialog
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
                  winner: currentGame.winner,
                  loser: currentGame.winner == username ? username2 : username,
                  winnerDifferencesFound:
                      currentGame.winner == username ? _counter1 : _counter2,
                  loserDifferencesFound:
                      currentGame.winner == username ? _counter2 : _counter1,
                  gameTime: _chronometerKey.currentState?.remainingTime ?? 0,
                );
                SocketService.socket.emit('leaveGameLimite', null);
                currentGame.gameEnded(true, gameStats);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MainPage(),
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
}
