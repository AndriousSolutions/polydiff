import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polydiff/components/game_card.dart';
import 'package:polydiff/services/game_card_template.dart';

class GameCardListComponent extends StatefulWidget {
  final int first;
  final int last;
  final List<GameCardTemplate> gameCards;

  const GameCardListComponent({
    super.key,
    required this.first,
    required this.last,
    required this.gameCards,
  });

  @override
  State createState() => _GameCardListComponentState();
}

class _GameCardListComponentState extends State<GameCardListComponent> {
  List<GameCardTemplate> get gameCardsSlice {
    if (widget.gameCards.isNotEmpty) {
      final int end = min(widget.gameCards.length, widget.last);
      return widget.gameCards.sublist(widget.first, end);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final currentSlice = gameCardsSlice;
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: currentSlice.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: GameCard(
              key: ValueKey(currentSlice[index].id),
              gameCard: currentSlice[index],
            ),
          );
        },
      ),
    );
  }
}
