import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'exam_provider.dart'; // To access storageServiceProvider
import 'pro_provider.dart';

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
  final bool _isPro;

  SlotNotifier(this._storageService, this._isPro)
      : super(SlotState(
          unlockedSlots: _isPro ? 9999 : _storageService.getUnlockedSlots(),
        ));

  Future<void> incrementSlot() async {
    // Save the real increment to storage even if Pro is active,
    // so they keep their progress if Pro expires.
    final realCount = _storageService.getUnlockedSlots() + 1;
    await _storageService.setUnlockedSlots(realCount);
    
    if (!_isPro) {
      state = state.copyWith(unlockedSlots: realCount);
    }
  }
}

final slotProvider = StateNotifierProvider<SlotNotifier, SlotState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final isPro = ref.watch(proAccessProvider);
  return SlotNotifier(storage, isPro);
});
