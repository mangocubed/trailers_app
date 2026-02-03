dynamic dateToJson(DateTime data) {
  return data.toString().split(' ').first;
}

Duration jsonToDuration(dynamic data) {
  final durationString = (data as String);

  final timePos = durationString.indexOf('T');

  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  if (durationString.startsWith('P')) {
    final periodString = durationString.substring(1, timePos >= 0 ? timePos : null);
    int start = 1;

    final yearsPos = periodString.indexOf('Y');

    if (yearsPos >= 0) {
      days = (int.tryParse(periodString.substring(start, yearsPos)) ?? 0) * 365;
      start = yearsPos + 1;
    }

    final monthsPos = periodString.indexOf('M');

    if (monthsPos >= 0) {
      days = days + ((int.tryParse(periodString.substring(start, monthsPos)) ?? 0) * 30);
      start = monthsPos + 1;
    }

    final weeksPos = periodString.indexOf('W');

    if (weeksPos >= 0) {
      days = days + ((int.tryParse(periodString.substring(start, weeksPos)) ?? 0) * 7);
      start = weeksPos + 1;
    }

    final daysPos = periodString.indexOf('D');

    if (daysPos >= 0) {
      days = days + (int.tryParse(periodString.substring(start, daysPos)) ?? 0);
      start = daysPos + 1;
    }
  }

  if (timePos >= 0) {
    final timeString = durationString.substring(timePos);
    int start = 1;

    final hoursPos = timeString.indexOf('H');

    if (hoursPos >= 0) {
      hours = int.tryParse(timeString.substring(start, hoursPos)) ?? 0;
      start = hoursPos + 1;
    }

    final minutesPos = timeString.indexOf('M');

    if (minutesPos >= 0) {
      minutes = int.tryParse(timeString.substring(start, minutesPos)) ?? 0;
      start = minutesPos + 1;
    }

    final secondsPos = timeString.indexOf('S');

    if (secondsPos >= 0) {
      seconds = int.tryParse(timeString.substring(start, secondsPos)) ?? 0;
      start = secondsPos + 1;
    }
  }

  return Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
}

Uri jsonToUri(dynamic data) {
  return Uri.parse(data);
}
