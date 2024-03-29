import 'package:intl/intl.dart';

String formatDueTime(DateTime dueTime) {
  DateFormat desiredFormat = DateFormat('HH:mm dd/MM');
  return desiredFormat.format(dueTime);
}
