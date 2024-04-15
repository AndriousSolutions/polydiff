// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:polydiff/pages/home_page.dart';
// import 'package:polydiff/services/camera.dart';
// import 'package:polydiff/services/image_from_server.dart';
// import 'package:polydiff/services/language.dart';
// import 'package:polydiff/services/localNotificationService.dart';
// import 'package:polydiff/services/socket.dart';
// import 'package:polydiff/services/theme.dart';
// import 'package:provider/provider.dart';
//
// // modif test
// Future main() async {
//   // Toggle this line to switch between dev and prod
//   await dotenv.load(fileName: 'env/.env.prod');
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
//           create: (context) => AvatarProvider(), child: App()),
//     );
//   });
// }
//
// class App extends StatelessWidget {
//   const App({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//         create: (context) => AppState(),
//         child: Consumer<AppState>(
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
//               localizationsDelegates: [
//                 GlobalMaterialLocalizations.delegate,
//                 GlobalWidgetsLocalizations.delegate,
//                 GlobalCupertinoLocalizations.delegate,
//               ],
//               supportedLocales: [
//                 const Locale('en', ''), // English
//                 const Locale('fr', ''), // French
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
// class AppState extends ChangeNotifier {
//   ThemeController themeService = ThemeController();
//   LanguageController languageService = LanguageController();
//
//   AppState() {
//     themeService.addListener(updateTheme);
//     languageService.addListener(updateLanguage);
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
//     themeService.removeListener(updateTheme);
//     languageService.removeListener(updateLanguage);
//     super.dispose();
//   }
// }
