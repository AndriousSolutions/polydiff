import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttery_framework/view.dart';
import 'package:polydiff/pages/home_page.dart';
import 'package:polydiff/services/camera.dart';
import 'package:polydiff/services/image_from_server.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/localNotificationService.dart';
import 'package:polydiff/services/socket.dart';
import 'package:polydiff/services/theme.dart';
import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends AppStatefulWidget {
  @override
  AppState createAppState() => _AppState();
}

class _AppState extends AppState {
  _AppState()
      : super(
          inInitAsync: () async {
            // Toggle this line to switch between dev and prod
            await dotenv.load(fileName: 'env/.env.dev');
//            await dotenv.load(fileName: 'env/.env.prod');
            await Camera.initialize();
            await LocalNotificationService().init();
            if (dotenv.isInitialized) {
              SocketService.initSocket();
            }
            // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            //     overlays: []);
            // await SystemChrome.setPreferredOrientations(
            //     [DeviceOrientation.landscapeLeft]);
            return dotenv.isInitialized;
          },
          controllers: [LanguageController(), ThemeController()],
          locale: LanguageController().currentLocale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('fr', 'FR'), // French
          ],
          title: 'PolyDiff',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ThemeController().currentColorScheme,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: HomePage(),
        );
}

// // modif test
// Future mainOLD() async {
//   // Toggle this line to switch between dev and prod
// //  await dotenv.load(fileName: 'env/.env.prod');
//   await dotenv.load(fileName: 'env/.env.dev');
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Camera.initialize();
//   await LocalNotificationService().init();
//   SocketService.initSocket();
//
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//   SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
//       .then((_) {
//     runApp(
//       ChangeNotifierProvider(
//           create: (context) => AvatarProvider(), child: AppOLD()),
//     );
//   });
// }
//
// class AppOLD extends StatelessWidget {
//   const AppOLD({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (context) => AppStateOLD(),
//         child: Consumer<AppStateOLD>(
//           builder: (context, appState, child) => Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(appState.themeService.isThemeDark
//                     ? 'assets/images/background.png'
//                     : 'assets/images/background_light.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: MaterialApp(
//               locale: appState.languageService.currentLocale,
//               localizationsDelegates: const [
//                 GlobalMaterialLocalizations.delegate,
//                 GlobalWidgetsLocalizations.delegate,
//                 GlobalCupertinoLocalizations.delegate,
//               ],
//               supportedLocales: const [
//                 Locale('en', ''), // English
//                 Locale('fr', ''), // French
//               ],
//               title: 'PolyDiff',
//               theme: ThemeData(
//                 useMaterial3: true,
//                 colorScheme: appState.themeService.currentColorScheme,
//                 scaffoldBackgroundColor: Colors.transparent,
//               ),
//               home: HomePage(),
//             ),
//           ),
//         ));
//   }
// }
//
// class AppStateOLD extends ChangeNotifier {
//   ThemeController themeService = ThemeController();
//   LanguageController languageService = LanguageController();
//
//   AppStateOLD() {
//     // themeService.addListener(updateTheme);
//     // languageService.addListener(updateLanguage);
//   }
//
//   void updateTheme() {
//     notifyListeners();
//   }
//
//   void updateLanguage() {
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     // themeService.removeListener(updateTheme);
//     // languageService.removeListener(updateLanguage);
//     super.dispose();
//   }
// }
