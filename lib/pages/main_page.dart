import 'package:flutter/services.dart';
import 'package:fluttery_framework/view.dart';
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
      classicGameButtonLabel = LanguageController().translate(
          frenchString: 'Mode classique', englishString: 'Classic Mode');
      limitedTimeGameButtonLabel = LanguageController().translate(
          frenchString: 'Mode temps limité',
          englishString: 'Limited Time Mode');
      storeButtonLabel = LanguageController()
          .translate(frenchString: 'Boutique', englishString: 'Store');
      logoutButtonLabel = LanguageController()
          .translate(frenchString: 'Déconnexion', englishString: 'Logout');

      buttons = [
        ButtonData(classicGameButtonLabel, () async {
          if (context.mounted) {
            await Navigator.push(
              //ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => SelectoPageWidget(),
              ),
            );
          }
        }),
        ButtonData(limitedTimeGameButtonLabel, () async {
          if (context.mounted) {
            await Navigator.push(
              //ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => LimitedSelecto(),
              ),
            );
          }
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
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              //ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (Route<dynamic> route) => false,
            );
          }
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
      canPop: false, // Prevents the user from navigating back to the login page
      child: LayoutBuilder(builder: (context, constraints) {
        final children = [
          // Expanded(
          //   flex: 1,
          //   child: Container(),
          // ),
          Flexible(
            flex: 3,
            child: Column(
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
          ),
          Flexible(
            flex: 2,
            child: Image.asset(
              'assets/images/logo1.png',
//              height: constraints.maxHeight * 0.5,
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Container(),
          // ),
        ];
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Remove back arrow from display
            title: Text(LanguageController()
                .translate(frenchString: 'Accueil', englishString: 'Home')),
            actions: <Widget>[
              Row(
                children: [
                  UserSettingsButton(refreshUserData, refreshButtonsLabel),
                  SizedBox(width: 10),
                  Text(LanguageController().translate(
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
              Center(
                child: context.isPortrait
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: children)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: children),
              ),
              Align(alignment: Alignment.bottomRight, child: MessageSideBar()),
            ],
          ),
        );
      }),
    );
  }
}

///
Future<void> systemUIMode() async {
  //
  if (_systemSet) {
    _systemSet = false;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([]);
  } else {
    _systemSet = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: []);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft]);
  }
}

/// A flag indicate what happens in the next call to _systemUIMode()
bool _systemSet = false;

// Dialog window
void backDialogWindow(BuildContext context) {
  //
  final style = TextButton.styleFrom(
    textStyle: Theme.of(context).textTheme.labelLarge,
  );
  showDialogBox(
    context,
    title: 'Exit Game?',
    content: Text(''),
    actions: [
      TextButton(
        style: style,
        child: const Text('OK'),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
      TextButton(
        style: style,
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
}

class ButtonData {
  final String label;
  final VoidCallback onPressed;

  ButtonData(this.label, this.onPressed);
}
