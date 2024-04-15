import 'package:flutter/material.dart';
import 'package:polydiff/components/game_constants.dart';
import 'package:polydiff/components/message_sidebar.dart';
import 'package:polydiff/components/select_lobby.dart';
import 'package:polydiff/components/waiting_page_limite.dart';
import 'package:polydiff/interfaces/game_access_type.dart';
import 'package:polydiff/pages/limited_time_page.dart';
import 'package:polydiff/services/communication.dart';
import 'package:polydiff/services/friends.dart';
import 'package:polydiff/services/game_card_template.dart';
import 'package:polydiff/services/game_info.dart';
import 'package:polydiff/services/interfaces/game_consts_interface.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/socket.dart';
import 'package:polydiff/services/user.dart';

class LimitedSelecto extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LimitedSelectoState createState() => _LimitedSelectoState();
}

class _LimitedSelectoState extends State<LimitedSelecto> {
  final CommunicationService _communicationService = CommunicationService();
  final GameInfoService gameInfoService = GameInfoService();

  List<int> cardOrder = [];
  late int nGameCards;
  late List<GameCardTemplate> gameCards;
  late String username;
  List<dynamic> lobbies = []; // a voir

  @override
  void initState() {
    super.initState();
    SocketService.socket.emit('getLobbiesLimite', {});
    SocketService.socket.on('updateLobbiesLimite', (data) async {
      print('updateLobbiesLimite $data');
      if (mounted) {
        var gameData = data as List;

        var filteredGames = await Future.wait(gameData.map((game) async {
          if (!await FriendsService.isUserAllowedInGame(game)) {
            return null;
          }
          return game;
        }).toList());
        // print('dataaaa $data');
        var filterstatus = data
            .where((game) => game['status'] == 0 || game['status'] == 4)
            .toList();
        // var actifGames = data.where((game) => game.status == 2).toList();
        setState(() {
          lobbies = filterstatus;
        });
      }
    });
    _configSockets();

    SocketService.socket.on('orderSent', (data) {
      if (mounted) {
        setState(() {
          cardOrder = data.order;
        });
      }
    });

    _downloadCards();

    username = User.username;
    SocketService.socket.on('startGameLimite', (data) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LimitedTimePage(),
        ),
      );
    });
  }

  void _downloadCards() async {
    print('Downloading game cards');
    var cards = await _communicationService.downloadGameCards();
    if (mounted) {
      setState(() {
        gameCards = cards;
        nGameCards = gameCards.length;
      });
    }
  }

  void _configSockets() {
    SocketService.socket.on('launchLobby', (data) {
      final constants = data as Constants;
      applyConstantsToGameInfo(data);
    });
  }

  void applyConstantsToGameInfo(Constants constants) {
    print('Applying constants to game info');
    print(constants);
    gameInfoService.initialTime = constants.initialTime;
    gameInfoService.penalty - constants.penalty;
    gameInfoService.timeWon = constants.timeWon;
    gameInfoService.cheatMode = constants.cheatMode;
    createLobby(GameAccessType.ALL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LanguageController().translate(
        frenchString: 'Partie temps limité',
        englishString: 'Limited time mode',
      ))),
      // backgroundColor: Colors.blue[50], // Couleur de fond de la page
      body: Stack(
        children: [
          Center(
            // Centre le contenu
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.7, // 50% of screen height
              width: MediaQuery.of(context).size.width * 0.7,
              padding: EdgeInsets.all(
                  20), // Espacement autour du contenu de la boîte
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius:
                    BorderRadius.circular(20), // Bord arrondi de la boîte
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Réduit la taille de la colonne à son contenu
                children: <Widget>[
                  Text(
                    LanguageController().translate(
                        frenchString: 'Créer une partie',
                        englishString: 'Create a game'),
                    textAlign: TextAlign.start, // Alignement du texte
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: () {
                        openConfigDialog(GameAccessType.ALL);
                      },
                      child: Text(
                        LanguageController().translate(
                            frenchString: 'Tous', englishString: 'All'),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        openConfigDialog(GameAccessType.FRIENDS_ONLY);
                      },
                      child: Text(
                        LanguageController().translate(
                            frenchString: 'Amis', englishString: 'Friends'),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        openConfigDialog(
                            GameAccessType.FRIENDS_AND_THEIR_FRIENDS);
                      },
                      child: Text(
                        LanguageController().translate(
                            frenchString: 'Amis++', englishString: 'Friends++'),
                      ),
                    ),
                  ]),
                  SizedBox(height: 20),
                  Text(
                    LanguageController().translate(
                        frenchString: 'Rejoindre une partie',
                        englishString: 'Join a game'),
                    textAlign: TextAlign.start, // Alignement du texte
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: PopupSelectLobbyComponent(
                      lobbies: lobbies,
                      onLobbySelected: (String lobbyId) {
                        onLobbySelected(lobbyId); // Appel direct ici
                      },
                    ),
                  ),
                  Text(LanguageController().translate(
                      frenchString: 'Observer une partie',
                      englishString: 'Watch a game')),
                ],
              ),
            ),
          ),
          Align(alignment: Alignment.bottomRight, child: MessageSideBar()),
        ],
      ),
    );
  }

// lobbies
  void joinGameById(String gameId) {
    print('Joining lobby with gameId: $gameId');
    SocketService.socket
        .emit('joinGameLimiteById', {'lobbyId': gameId, 'username': username});
    _openDialogLoad();
  }

  void onLobbySelected(String gameId) {
    print('Selected Lobby: $gameId');
    return joinGameById(gameId);
  }

  void leaveGame() {
    SocketService.socket.emit('leaveGame', null);
  }

  _openDialogLoad() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                CircularProgressIndicator(),
                Text('En attente du lancement de la partie...'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                leaveGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void createLobby(GameAccessType gameAccessType) {
    print('Creating lobby');
    SocketService.socket.emit('createGameLimite',
        {'username': username, 'gameAccessType': gameAccessType.index});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaintingPageLimite(), // change to waiting page
      ),
    );
  }

  openConfigDialog(GameAccessType gameAccessType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameConstantsScreen(
            gameAccessType: gameAccessType), // change to waiting page
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    SocketService.socket.off('orderSent');
    SocketService.socket.off('startGameLimite');
    SocketService.socket.off('updateLobbiesLimite');
  }
}
