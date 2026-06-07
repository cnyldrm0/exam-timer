import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../services/storage_service.dart';
import 'exam_provider.dart';

final motivationProvider = AsyncNotifierProvider<MotivationNotifier, String>(() {
  return MotivationNotifier();
});

class MotivationNotifier extends AsyncNotifier<String> {
  List<String> _allQuotes = [];

  @override
  Future<String> build() async {
    final storage = ref.watch(storageServiceProvider);
    if (storage == null) return "Bugün harika bir gün olacak!";

    if (_allQuotes.isEmpty) {
      await _loadQuotes();
    }

    if (_allQuotes.isEmpty) return "Harekete geç!";

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final storedDate = storage.getMotivationDate();
    final storedIndex = storage.getMotivationIndex();

    String quote;
    if (storedDate == today && storedIndex != null && storedIndex < _allQuotes.length) {
      quote = _allQuotes[storedIndex];
    } else {
      int newIndex = _generateRandomIndex(storedIndex);
      await storage.saveMotivationData(newIndex, today);
      quote = _allQuotes[newIndex];
    }
    
    _syncWithWidget(quote);
    return quote;
  }

  Future<void> _loadQuotes() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/motivation_messages.json');
      final data = json.decode(response);
      if (data is List && data.isNotEmpty) {
        final List<dynamic> quotesList = data[0]['quotes'] ?? [];
        _allQuotes = quotesList.map((e) => e.toString()).toList();
      }
    } catch (e) {
      _allQuotes = ["Başarı, hazırlık ve fırsatın buluştuğu noktadır."];
    }
  }

  int _generateRandomIndex(int? excludeIndex) {
    if (_allQuotes.length <= 1) return 0;
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(_allQuotes.length);
    } while (newIndex == excludeIndex);
    return newIndex;
  }

  Future<void> nextQuote() async {
    final storage = ref.read(storageServiceProvider);
    if (storage == null || _allQuotes.isEmpty) return;

    final currentIndex = storage.getMotivationIndex();
    final newIndex = _generateRandomIndex(currentIndex);
    final String quote = _allQuotes[newIndex];

    await storage.saveMotivationIndex(newIndex);
    state = AsyncData(quote);
    
    await _syncWithWidget(quote);
  }

  Future<void> _syncWithWidget(String quote) async {
    await HomeWidget.saveWidgetData<String>('motivation_quote', quote);
    await HomeWidget.updateWidget(
      name: 'MediumWidgetReceiver',
      androidName: 'MediumWidgetReceiver',
    );
  }
}
