import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'exam_provider.dart'; // To access storageServiceProvider

class SlotState {
  final int unlockedSlots;

  SlotState({required this.unlockedSlots});

  SlotState copyWith({int? unlockedSlots}) {
    return SlotState(
      unlockedSlots: unlockedSlots ?? this.unlockedSlots,
    );
  }
}

class SlotNotifier extends StateNotifier<SlotState> {
  final StorageService _storageService;

  SlotNotifier(this._storageService)
      : super(SlotState(
          unlockedSlots: _storageService.getUnlockedSlots(),
        ));

  Future<void> incrementSlot() async {
    final newCount = state.unlockedSlots + 1;
    await _storageService.setUnlockedSlots(newCount);
    state = state.copyWith(unlockedSlots: newCount);
  }
}

final slotProvider = StateNotifierProvider<SlotNotifier, SlotState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SlotNotifier(storage);
});
