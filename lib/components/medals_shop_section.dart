import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:polydiff/services/items.dart';
import 'package:polydiff/services/language.dart';

import '../services/user.dart';

class MedalsSection extends StatefulWidget {
  final Function(int) updateBalance;
  MedalsSection({required this.updateBalance});

  @override
  State createState() => _MedalsSectionState();
}

class _MedalsSectionState extends State<MedalsSection> {
  final ItemService itemService = ItemService();
  late Future<List<Item>> boughtItemsFuture;
  List<Item> boughtItems = [];

  @override
  void initState() {
    super.initState();
    // Assurez-vous d'avoir l'username correct ici, potentiellement le passer en tant que paramètre ou le stocker de manière accessible
    boughtItemsFuture = itemService.getBoughtItems(User.username).then((items) {
      boughtItems = items;
      return items;
    });
    print('${User.username}, User.username');
  }

  void fetchBoughtItems() async {
    var items = await itemService.getBoughtItems(User.username);
    setState(() {
      boughtItems = items;
    });
  }

  bool isOwned(String medalName, List<Item> boughtItems) {
    return boughtItems.any((item) => item.name == medalName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: boughtItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final boughtItems = snapshot.data!;
            return buildMedalsList(boughtItems);
          } else if (snapshot.hasError) {
            // Modifiez cette partie pour afficher plus de détails sur l'erreur
            return Text(LanguageController().translate(
                    frenchString:
                        'Erreur lors du chargement des articles achetés',
                    englishString: 'Error loading bought items') +
                ': ${snapshot.error}');
          }
        }
        return CircularProgressIndicator(); // Chargement en cours
      },
    );
  }

  Widget buildMedalsList(List<Item> boughtItems) {
    List<Item> medals = itemService.getMedals(); // Obtenez les items du service

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a2b3c),
            Color(0xFF2d3e4f),
          ],
        ),
      ),
      width: // 80% of screen
          MediaQuery.of(context).size.width * 0.8,
      height: 220,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(height: 20), // Add distance
                Text(
                  LanguageController().translate(
                      frenchString: 'Médailles', englishString: 'Medals'),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20), // Add distance

                Text(
                  LanguageController().translate(
                      frenchString:
                          'Améliorez votre expérience de jeu avec ces médailles exclusives !',
                      englishString:
                          'Improve your gaming experience with these exclusive medals!'),
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: medals.length,
              itemBuilder: (context, index) {
                Item medal = medals[index];
                bool owned = isOwned(medal.name, boughtItems);

                return Flexible(
                  flex: 1,
                  child: Container(
                    width: 150, // Ajustez selon la taille de vos widgets
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1a2b3c),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Image.asset(medal.path!, width: 80, height: 80),
                        Text(medal.name, style: TextStyle(color: Colors.white)),
                        SizedBox(height: 4),
                        owned
                            ? Text(
                                LanguageController().translate(
                                    frenchString: 'Acheté',
                                    englishString: 'Owned'),
                                style: TextStyle(color: Colors.green))
                            : ElevatedButton(
                                onPressed: () => buyMedal(medal),
                                child: Text('${medal.price} dinars'),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buyMedal(Item medal) async {
    // Implémentez la logique d'achat ici
    final body = json.encode({
      'item': {
        'path': medal.path,
        'name': medal.name,
        'type': medal.type,
        'price': medal.price,
      }
    });

    final response = await http.post(
      Uri.parse(
          '${dotenv.env['SERVER_URL_AND_PORT']!}api/fs/players/${User.username}/shop'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    final responseData = json.decode(response.body);
    try {
      if (response.statusCode == 200) {
        widget.updateBalance(medal.price);
        setState(() {
          boughtItems.add(medal);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ??
                  LanguageController().translate(
                      frenchString: 'Acheté', englishString: 'Owned'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ??
                LanguageController().translate(
                    englishString: 'Purchase error',
                    frenchString: 'Erreur d\'achat.')),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageController().translate(
              englishString:
                  'An error occurred while communicating with the server.',
              frenchString:
                  'Une erreur est survenue lors de la communication avec le serveur.')),
        ),
      );
    }
  }
}
