import 'package:tempo/tempo.dart';

class DateUtils {
  static OffsetDateTime dateWithYear(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0, int nanosecond = 0, int timezone = 0]) {
    return OffsetDateTime(ZoneOffset.fromDuration(Duration(seconds: timezone * 60)), year, month, day, hour, minute, second, nanosecond);
  }

  static OffsetDateTime? dateWithTimeString(String string) {
    if (string.length < 30) {
      return null;
    }

    String time = string.substring(string.length - 18);
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(3, 2));
    int second = int.parse(time.substring(6, 2));
    int nanosecond = int.parse(time.substring(9, 7));
    String meridian = time.substring(16, 2);

    if (meridian == "AM") {
      if (hour == 12) {
        hour = 0;
      }
    } else {
      if (hour < 12) {
        hour += 12;
      }
    }

    return dateWithYear(1900, 1, 1, hour, minute, second, nanosecond * 100, 0);
  }
}