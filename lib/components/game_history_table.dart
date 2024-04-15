import 'package:polydiff/components/generic_history_table.dart';
import 'package:polydiff/services/language.dart';
import 'package:polydiff/services/user.dart';

class GameHistoryTable extends GenericHistoryTable {
  GameHistoryTable()
      : super(
            data: User.gameHistory.map((entry) {
              return MapEntry(entry.date, entry.wonGame == true ? '👑' : '❌');
            }).toList(),
            dataLabel: LanguageController().translate(
                frenchString: 'Partie gagnée', englishString: 'Game won'));
}
