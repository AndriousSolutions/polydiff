import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttery_framework/view.dart';
import 'package:polydiff/pages/home_page.dart';
import 'package:polydiff/services/camera.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/localNotificationService.dart';
import 'package:polydiff/services/socket.dart';
import 'package:polydiff/services/theme.dart';

void main() => runApp(App());

class App extends AppStatefulWidget {
  App({super.key, this.env});

  // Supply an optional environment indicator.
  final String? env;

  @override
  AppState createAppState() => _AppState();
}

class _AppState extends AppState<App> {
  _AppState()
      : super(
          controllers: [LanguageController(), ThemeController()],
          locale: LanguageController().currentLocale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('fr', 'FR'),
          ],
          title: 'PolyDiff',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ThemeController().currentColorScheme,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: HomePage(),
        );

  @override
  onInitAsync() async {
    await _setupEnvironment();
    await Camera.initialize();
    await LocalNotificationService().init();
    if (dotenv.isInitialized) {
      SocketService.initSocket();
    }
    return dotenv.isInitialized;
  }

  // Set the appropriate environment
  Future<void> _setupEnvironment() async {
    //
    String env;
    if (widget.env != null) {
      env = widget.env!.trim().toLowerCase();
    } else {
      env = '';
    }

    // Run 'dev' unless 'prod' is specified.
    String fileName;
    if (env == 'prod' || (env != 'dev' && !inDebugMode)) {
      fileName = 'env/.env.prod';
    } else {
      fileName = 'env/.env.dev';
    }
    await dotenv.load(fileName: fileName);
  }
}
