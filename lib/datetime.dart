extension DateTimeExt on DateTime {
  // Elapsed time since this DateTime instance
  Duration elapsed([DateTime? end]) => (end ?? DateTime.now()).difference(this);
}
