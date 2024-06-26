import 'package:fluttery_framework/controller.dart';
import 'package:polydiff/services/http_request_tool.dart';
import 'package:polydiff/services/user.dart';

class LanguageController extends StateXController {
  factory LanguageController() => _this ??= LanguageController._();
  LanguageController._();
  static LanguageController? _this;

  bool isLanguageFrench = true;
  Locale currentLocale = Locale('fr', 'FR');

  // changes current session display language
  setLanguage(bool isFrench) {
    isLanguageFrench = isFrench;
    currentLocale = isFrench ? Locale('fr', 'FR') : Locale('en', 'US');
    setState(() {});
  }

  // Save current state to db
  saveLanguage() {
    HttpRequestTool.basicPatch('api/fs/players/${User.username}/language', {
      'isLanguageFrench': isLanguageFrench,
    });
  }

  selectLanguage(bool isFrench) {
    setLanguage(isFrench);
    saveLanguage();
  }

  translate({required String frenchString, required String englishString}) {
    return isLanguageFrench ? frenchString : englishString;
  }
}
