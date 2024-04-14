import 'dart:convert'; // pour utiliser json.decode

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ItemService {
  // URL de votre API ou serveur
  // final String baseUrl = 'http://10.200.40.178:3000/';
  final String baseUrl = '${dotenv.env['SERVER_URL_AND_PORT']}';

  List<String> allAppAvatars = List.generate(6, (i) => 'avatar${i + 4}.png');

  String getAvatarPath(String avatar) {
    return '${baseUrl}avatars/$avatar';
  }

  List<String> getAllAvatars() {
    print('$baseUrl baseUrl');
    return allAppAvatars;
  }

  List<Item> getMedals() {
    List<Item> medals = [
      Item(
        name: 'Status Argent',
        path: 'assets/medals/silver.png',
        price: 50,
        type: 'Medal',
      ),
      Item(
        name: 'Status Bronze',
        path: 'assets/medals/bronze.png',
        price: 25,
        type: 'Medal',
      ),
      Item(
        name: 'Status Or',
        path: 'assets/medals/gold.png',
        price: 100,
        type: 'Medal',
      )
    ];
    return medals;
  }

  List<Item> getSounds() {
    List<Item> sounds = [
      Item(
        path: 'special-audios/fail-sound.mp3',
        name: 'Son d\'échec',
        price: 50,
        type: 'Sound',
      ),
      Item(
        path: 'special-audios/success-sound.mp3',
        name: 'Son de succès',
        price: 50,
        type: 'Sound',
      ),
      Item(
        path: 'special-audios/win-sound.mp3',
        name: 'Son de victoire',
        price: 50,
        type: 'Sound',
      )
    ];
    return sounds;
  }


  Future<List<Item>> getBoughtItems(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/fs/players/$username/bought-items'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('uri: ${baseUrl}api/fs/players/$username/bought-medals');
      print('${response.statusCode} response status code');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        print('decodedData: $decodedData');

        // Vérifiez que 'boughtItems' existe et n'est pas null
        if (decodedData.containsKey('boughtItems') &&
            decodedData['boughtItems'] != null) {
          List<dynamic> boughtItemsJson = decodedData['boughtItems'];
          print('boughtItemsJson: $boughtItemsJson');

          List<Item> boughtItems =
              boughtItemsJson.map<Item>((json) => Item.fromJson(json)).toList();
          print('boughtItems: $boughtItems');
          return boughtItems;
        } else {
          // Retourne une liste vide si 'boughtItems' est absent ou null
          print("'boughtItems' is null or missing");
          return [];
        }
      } else {
        // Gérez d'autres statuts de réponse ou erreurs ici
        print('Failed to load bought items: ${response.body}');
        throw Exception('Failed to load bought items');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Error occurred: $e');
    }
  }
}

// Définition de la classe Item pour correspondre au format des données renvoyées par votre serveur
class Item {
  final String? path;
  final String name;
  final String type;
  final int price;

  Item({
    this.path,
    required this.name,
    required this.type,
    required this.price,
  });

  // Créez un constructeur nommé pour créer un objet Item à partir d'un json
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      path: json['path'],
      name: json['name'],
      type: json['type'],
      price: json['price'],
    );
  }
}
