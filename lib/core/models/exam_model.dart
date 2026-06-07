enum ExamCategory {
  custom('Manuel Eklenen'),
  popular('Popüler Sınavlar'),
  academicLanguage('Akademik ve Dil'),
  medical('Sağlık'),
  other('Diğer');

  final String displayName;
  const ExamCategory(this.displayName);
}

class ExamModel {
  final String id;
  final String title;
  final DateTime date;
  final ExamCategory category;
  final String? resultDate;
  final DateTime typicalSeasonStart;
  final bool isCustom;

  ExamModel({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    this.resultDate,
    required this.typicalSeasonStart,
    this.isCustom = false,
  });

  /// Factory constructor for user-created custom exams.
  factory ExamModel.custom({
    required String title,
    required DateTime date,
    String? code,
  }) {
    final id = code?.isNotEmpty == true
        ? code!
        : 'CUSTOM-${date.millisecondsSinceEpoch}';
    final seasonStart = DateTime(date.year - (date.month < 9 ? 1 : 0), 9, 1);
    return ExamModel(
      id: id,
      title: title,
      date: date,
      category: ExamCategory.custom,
      typicalSeasonStart: seasonStart,
      isCustom: true,
    );
  }

  String get shortTitle {
    final String fullTitle = title.toLowerCase();
    
    if (fullTitle.contains('yükseköğretim kurumları sınavı')) {
      if (fullTitle.contains('temel yeterlilik')) return 'YKS (TYT)';
      if (fullTitle.contains('alan yeterlilik')) return 'YKS (AYT)';
      if (fullTitle.contains('yabancı dil testi')) return 'YKS (YDT)';
      return 'YKS';
    }
    
    if (fullTitle.contains('kamu personel seçme sınavı')) {
      if (fullTitle.contains('ön lisans')) return 'KPSS (Önlisans)';
      if (fullTitle.contains('ortaöğretim')) return 'KPSS (Ortaöğretim)';
      if (fullTitle.contains('genel yetenek')) return 'KPSS (Lisans)';
      return 'KPSS';
    }

    if (fullTitle.contains('akademik personel ve lisansüstü eğitimi giriş sınavı')) return 'ALES';
    if (fullTitle.contains('dikey geçiş sınavı')) return 'DGS';
    if (fullTitle.contains('millî savunma üniversitesi')) return 'MSÜ';
    if (fullTitle.contains('yükseköğretim kurumları yabancı dil sınavı')) return 'YÖKDİL';
    if (fullTitle.contains('yabancı dil bilgisi seviye tespit sınavı')) return 'YDS';
    if (fullTitle.contains('tıpta uzmanlık eğitimi giriş sınavı')) return 'TUS';
    if (fullTitle.contains('diş hekimliğinde uzmanlık eğitimi giriş sınavı')) return 'DUS';
    if (fullTitle.contains('engelli kamu personel seçme sınavı')) return 'EKPSS';
    
    if (isCustom) return title;
    return id.replaceAll('2026-', '');
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
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

    final String code = (json['sinav_kodu'] as String).toUpperCase();
    ExamCategory category = ExamCategory.other;

    if (code.contains('YKS') || code.contains('KPSS') || code.contains('DGS') || code.contains('MSÜ')) {
      category = ExamCategory.popular;
    } else if (code.contains('ALES') || code.contains('YDS') || code.contains('YÖKDİL') || code.contains('TEP')) {
      category = ExamCategory.academicLanguage;
    } else if (code.contains('TUS') || code.contains('DUS') || code.contains('YDUS') || code.contains('STS')) {
      category = ExamCategory.medical;
    }

    return ExamModel(
      id: json['sinav_kodu'] as String,
      title: json['sinav_adi'] as String,
      date: examDate,
      category: category,
      resultDate: json['sonuc_tarihi'] as String?,
      typicalSeasonStart: seasonStart,
    );
  }

  /// Returns a copy of this exam with only the [date] changed.
  ExamModel copyWithDate(DateTime newDate) {
    return ExamModel(
      id: id,
      title: title,
      date: newDate,
      category: category,
      resultDate: resultDate,
      typicalSeasonStart: typicalSeasonStart,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortTitle': shortTitle,
      'date': date.toIso8601String(),
      'category': category.name,
      'resultDate': resultDate,
      'typicalSeasonStart': typicalSeasonStart.toIso8601String(),
      'isCustom': isCustom,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
