// shop_page.dart
import 'package:flutter/material.dart';
import 'package:polydiff/components/avatar-shop-section.dart';
import 'package:polydiff/components/medals-shop-section.dart';
import 'package:polydiff/components/message-sidebar.dart';
import 'package:polydiff/components/shop-wheel.dart';
import 'package:polydiff/components/sounds-section.dart';
import 'package:polydiff/pages/main-page.dart';
import 'package:polydiff/services/items.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/user.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ItemService itemService = ItemService();
  final int wheelPrice = 5;
  late Future<List<Item>> boughtItemsFuture;
  List<Item> boughtItems = [];

  @override
  void initState() {
    super.initState();
    fetchBoughtItems();
  }

  void fetchBoughtItems() async {
    var items = await itemService.getBoughtItems(User.username);
    setState(() {
      boughtItems = items;
    });
  }

  bool isOwned() {
    return boughtItems.any((item) => item.name == 'Multiplicateur x2');
  }

  void updateUserBalance(int cost) {
    setState(() {
      User.dinarsAmount -= cost;
    });
  }

  void openWheelDialog(BuildContext context) {
    if (User.dinarsAmount < wheelPrice) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              LanguageService().translate(
                frenchString: 'Solde insuffisant',
                englishString: 'Insufficient balance',
              ),
            ),
            content: Text(
              LanguageService().translate(
                frenchString:
                    'Vous n\'avez pas assez de dinars pour ouvrir la roue. Jouez à des jeux pour gagner plus de dinars.',
                englishString:
                    'You do not have enough dinars to open the wheel. Play games to earn more dinars.',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  LanguageService().translate(
                    frenchString: 'Fermer',
                    englishString: 'Close',
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    } else if (isOwned()) {
      print('already owned');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              LanguageService().translate(
                frenchString: 'Déjà possédé',
                englishString: 'Already owned',
              ),
            ),
            content: Text(
              LanguageService().translate(
                frenchString:
                    'Vous avez déjà acheté un multiplicateur de points. Vous ne pouvez pas en acheter un autre.',
                englishString:
                    'You have already purchased a points multiplier. You cannot purchase another one.',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  LanguageService().translate(
                    frenchString: 'Fermer',
                    englishString: 'Close',
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    setState(() {
      User.dinarsAmount -= wheelPrice;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            // Définissez les dimensions si nécessaire
            width: double.maxFinite,
            child:
                WheelPage(), // Assurez-vous que c'est le nom de votre widget de roue
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                LanguageService().translate(
                  frenchString: 'Fermer',
                  englishString: 'Close',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boutique de Jeu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Insérer l'action souhaitée ici. Par exemple, pour revenir à la première page :
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainPage()), // Replace NewPage with the desired page
            );
            // Ou, pour naviguer vers une nouvelle page (remplaçant la pile de navigation) :
            // Navigator.of(context).pushReplacementNamed('/menu');
          },
        ),
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => openWheelDialog(context),
                  child: Text(
                    LanguageService().translate(
                      frenchString:
                          'Faites tourner la roue de fortune contre 5 dinars',
                      englishString: 'Swing the fortune wheel for 5 dinars',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Row(
                  children: [
                    Text(
                      LanguageService().translate(
                        frenchString: 'Solde actuel: ',
                        englishString: 'Current balance: ',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${User.dinarsAmount} dinars',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.yellow[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    MedalsSection(updateBalance: updateUserBalance),
                    AvatarsSection(updateBalance: updateUserBalance),
                    SoundsSection(updateBalance: updateUserBalance),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: MessageSideBar(),
          ),
        ],
      ),
    );
  }
}
