import 'package:flutter/material.dart';
import 'package:polydiff/components/limited_selecto.dart';
import 'package:polydiff/components/message_sidebar.dart';
import 'package:polydiff/components/user_settings_button.dart';
import 'package:polydiff/pages/home_page.dart';
import 'package:polydiff/pages/selecto_page.dart';
import 'package:polydiff/pages/shop_page.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/login.dart';
import 'package:polydiff/services/user.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late Container avatar;
  late Text username;
  late String classicGameButtonLabel;
  late String limitedTimeGameButtonLabel;
  late String storeButtonLabel;
  late String logoutButtonLabel;

  late List<ButtonData> buttons;

  @override
  void initState() {
    super.initState();
    refreshUserData();
    refreshButtonsLabel();
  }

  void refreshButtonsLabel() {
    setState(() {
      classicGameButtonLabel = LanguageService().translate(
          frenchString: 'Mode classique', englishString: 'Classic Mode');
      limitedTimeGameButtonLabel = LanguageService().translate(
          frenchString: 'Mode temps limité',
          englishString: 'Limited Time Mode');
      storeButtonLabel = LanguageService()
          .translate(frenchString: 'Boutique', englishString: 'Store');
      logoutButtonLabel = LanguageService()
          .translate(frenchString: 'Déconnexion', englishString: 'Logout');

      buttons = [
        ButtonData(classicGameButtonLabel, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectoPageWidget(),
            ),
          );
        }),
        ButtonData(limitedTimeGameButtonLabel, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LimitedSelecto(),
            ),
          );
        }),
        ButtonData(
          storeButtonLabel,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShopPage(),
              ),
            );
          },
        ),
        ButtonData(logoutButtonLabel, () async {
          await LoginService.logout();
          User.username = '';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }),
      ];
    });
  }

  void refreshUserData() {
    setState(() {
      avatar = User.getAvatar();
      username = Text(User.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop:
            false, // Prevents the user from navigating back to the login page
        child: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading:
                  false, // Remove back arrow from display
              title: Text(LanguageService()
                  .translate(frenchString: 'Accueil', englishString: 'Home')),
              actions: <Widget>[
                Row(
                  children: [
                    UserSettingsButton(refreshUserData, refreshButtonsLabel),
                    SizedBox(width: 10),
                    Text(LanguageService().translate(
                            frenchString: 'Bonjour ', englishString: 'Hi ') +
                        User.username),
                    SizedBox(width: 10),
                    User.avatar,
                  ],
                )
              ],
            ),
            body: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var button in buttons)
                          Column(
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: button.onPressed,
                                  child: Text(button.label),
                                ),
                              ),
                              if (button != buttons.last) SizedBox(height: 20),
                            ],
                          ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/logo1.png',
                      height: constraints.maxHeight * 0.5,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
                Align(
                    alignment: Alignment.bottomRight, child: MessageSideBar()),
              ],
            ),
          );
        }));
  }
}

class ButtonData {
  final String label;
  final VoidCallback onPressed;

  ButtonData(this.label, this.onPressed);
}
