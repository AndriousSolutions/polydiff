import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttery_framework/view.dart';
import 'package:http/http.dart';
import 'package:polydiff/components/custom_text_field.dart';
import 'package:polydiff/pages/account_creation_page.dart';
import 'package:polydiff/pages/main_page.dart';
import 'package:polydiff/services/device_unlock.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/login.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key});
  @override
  LoginFieldsState createState() => LoginFieldsState();
}

class LoginFieldsState extends State<LoginFields> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final lang = LanguageController();
    return SizedBox(
      child: Column(
        children: [
          CustomTextField(
              controller: username,
              labelText: lang.translate(
                  frenchString: "Nom d'utilisateur :",
                  englishString: 'Username :'),
              obscureText: false),
          CustomTextField(
              controller: password,
              labelText: lang.translate(
                  frenchString: 'Mot de passe :', englishString: 'Password :'),
              obscureText: true),
          HomeButton(
            onPressed: () async {
              login(username.text, password.text);
            },
            text: lang.translate(
                frenchString: 'Connexion', englishString: 'Login'),
          ),
          HomeButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountCreationPage()),
              );
            },
            text: lang.translate(
                frenchString: 'Inscription', englishString: 'Sign up'),
          ),
          FutureBuilder<Map<String, String>>(
            future: DeviceUnlock.getStoredCredentials(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                bool hasCredentials = snapshot.data != null &&
                    snapshot.data!['username'] != '' &&
                    snapshot.data!['password'] != '';
                return HomeButton(
                  onPressed: hasCredentials
                      ? () {
                          openLastSession();
                        }
                      : null,
                  text: lang.translate(
                      frenchString: 'Ouvrir la dernière session',
                      englishString: 'Open last session'),
                );
              } else {
                return HomeButton(
                  onPressed: null,
                  text: lang.translate(
                    frenchString: 'Ouvrir la dernière session',
                    englishString: 'Open last session',
                  ),
                );
              }
            },
          ),
          if (dotenv.env['IS_DEV'] == 'true')
            HomeButton(
              onPressed: () async {
                login('qqq', 'qqqqqq');
              },
              text: 'IF dev login -> qqq',
            ),
          if (dotenv.env['IS_DEV'] == 'true')
            HomeButton(
              onPressed: () async {
                login('aaa', 'aaaaaa');
              },
              text: 'IF dev login -> aaa',
            ),
        ],
      ),
    );
  }

  login(String username, String password) async {
    Response? response;
    try {
      response = await LoginService.login(username, password);
    } catch (e, stack) {
      App.catchError(e, stack: stack, library: 'login_fields');
      if (context.mounted) {
        showBox(
            //ignore: use_build_context_synchronously
            context: context,
            text: LanguageController().translate(
              frenchString: 'Connexion échouée',
              englishString: 'Login unsuccessful',
            ));
      }
    }
    if (response != null) {
      if (response.statusCode == 200) {
        print('Logged in');
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'password', value: password);
        toMainPage();
      } else {
        print('Credentials invalid');
        String message = jsonDecode(response.body)['message'];
        credentialsInvalidPopup(message);
      }
    }
  }

  toMainPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainPage(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  credentialsInvalidPopup(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('⛔'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  openLastSession() async {
    bool isUnlocked = await DeviceUnlock.unlockDevice();
    if (isUnlocked) {
      Map<String, String> credentials =
          await DeviceUnlock.getStoredCredentials();
      login(credentials['username']!, credentials['password']!);
    }
  }
}

class HomeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  HomeButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            Color(0xFF0D6EFD),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
