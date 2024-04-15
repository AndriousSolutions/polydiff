import 'package:polydiff/components/generic_history_table.dart';
import 'package:polydiff/services/user.dart';

class ConnectionHistoryTable extends GenericHistoryTable {
  ConnectionHistoryTable()
      : super(
            data: User.connectionHistory.map((entry) {
              return MapEntry(entry.date, entry.action);
            }).toList(),
            dataLabel: 'Action');
}
