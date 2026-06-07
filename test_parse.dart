import 'dart:convert';
import 'dart:io';

class ExamModel {
  static void fromJson(Map<String, dynamic> json) {
    String dateStr = json['sinav_tarihi'] as String;
    List<String> parts = dateStr.split(' ');
    List<String> dateParts = parts[0].split('.');
    
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    int hour = 10;
    int minute = 15;

    if (parts.length > 1) {
      List<String> timeParts = parts[1].split(':');
      hour = int.parse(timeParts[0]);
      minute = int.parse(timeParts[1]);
    }

    final examDate = DateTime(year, month, day, hour, minute);
    final seasonStart = DateTime(year - (month < 9 ? 1 : 0), 9, 1);
  }
}

void main() {
  try {
    final response = File('lib/assets/exam_calendar.json').readAsStringSync();
    final List<dynamic> data = json.decode(response);
    
    var parsed = data
        .map((j) => ExamModel.fromJson(j as Map<String, dynamic>))
        .toList();
    print("Success");
  } catch (e, stack) {
    print("Error: $e");
    print(stack);
  }
}
