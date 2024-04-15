import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polydiff/components/message_sidebar.dart';
import 'package:polydiff/pages/main_page.dart';
import 'package:polydiff/services/language.dart';

import '../components/game_card_list.dart';
import '../services/communication.dart';
import '../services/consts.dart' as consts;
import '../services/game_card_template.dart';

class SelectoPageWidget extends StatefulWidget {
  @override
  SelectoPageWidgetState createState() => SelectoPageWidgetState();
}

class SelectoPageWidgetState extends State<SelectoPageWidget> {
  final CommunicationService _communicationService = CommunicationService();
  int _first = 0;
  int _last = 4;
  List<GameCardTemplate> _gameCards = [];
  bool _isSelectoPage = true;

  @override
  void initState() {
    super.initState();
    _downloadCards();
  }

  void _downloadCards() async {
    print('Downloading game cards');
    var cards = await _communicationService.downloadGameCards();
    setState(() {
      _gameCards = cards;
      _last = min(_gameCards.length, consts.Consts.CARDS_BY_PAGE);
    });
  }

  void _increment() {
    int newLast = _first + consts.Consts.CARDS_BY_PAGE;
    if (newLast < _gameCards.length) {
      setState(() {
        _first = newLast;
        _last = min(_gameCards.length, _last + consts.Consts.CARDS_BY_PAGE);
      });
    }
  }

  void _decrement() {
    int newFirst = _first - consts.Consts.CARDS_BY_PAGE;
    if (newFirst >= 0) {
      setState(() {
        _first = newFirst;
        _last = _first + consts.Consts.CARDS_BY_PAGE;
      });
    }
  }

  bool _isNextPage() {
    return _last < _gameCards.length;
  }

  @override
  Widget build(BuildContext context) {
    print(
        'First: $_first, Last: $_last, Game Cards Length: ${_gameCards.length}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageController().translate(
            frenchString: 'Partie classique',
            englishString: 'Classic mode',
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: _first == 0 ? null : _decrement,
            child: Icon(Icons.arrow_back),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: !_isNextPage() ? null : _increment,
            child: Icon(Icons.arrow_forward),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(children: [
        Expanded(
          child: GameCardListComponent(
            gameCards: _gameCards,
            first: _first,
            last: _last,
          ), // Affiche les game cards ici
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: MessageSideBar(),
        ),
      ]),
    );
  }
}
