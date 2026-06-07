// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Exam Timer';

  @override
  String get mainMenu => 'Home';

  @override
  String get widget => 'Widget';

  @override
  String get settings => 'Settings';

  @override
  String get widgetStudio => 'WIDGET STUDIO';

  @override
  String get applyAndAdd => 'APPLY AND ADD';

  @override
  String get howToAddWidget => 'How to Add a Widget?';

  @override
  String get tutorialStep1 => 'Long press an empty space on your home screen.';

  @override
  String get tutorialStep2 => 'Tap \'Widgets\' or \'Tools\'.';

  @override
  String get tutorialStep3 => 'Find the \'Exam Timer\' app.';

  @override
  String get tutorialStep4 => 'Drag and drop the widget onto your home screen.';

  @override
  String get understood => 'UNDERSTOOD';

  @override
  String get exam => 'Exam';

  @override
  String get appearance => 'Appearance';

  @override
  String get style => 'Style';

  @override
  String get whichExamToShow => 'Which Exam to Show?';

  @override
  String get opacity => 'Opacity';

  @override
  String get blur => 'Blur';

  @override
  String get widgetOptimizedInfo =>
      'Note: Widget is optimized to show Day and Hour on the home screen.';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get days => 'DAYS';

  @override
  String get hours => 'HOURS';

  @override
  String get mins => 'MINS';

  @override
  String get secs => 'SECS';

  @override
  String get remaining => 'REMAINING';

  @override
  String get examCompleted => 'EXAM COMPLETED';

  @override
  String get daysLeft => 'DAYS LEFT';

  @override
  String get welcome => 'WELCOME';

  @override
  String get motivationTitle => 'MOTIVATION OF THE DAY';

  @override
  String get refreshQuote => 'Refresh Quote';

  @override
  String get timeLeftToExams => 'Time Remaining for Exams';

  @override
  String get noExamSelected => 'No Exam Selected Yet';

  @override
  String get addExam => 'ADD EXAM';

  @override
  String get stopTracking => 'Stop Tracking Exam';

  @override
  String get trackingStoppedMessage =>
      'Exam tracking stopped. You can edit your exam preferences in Settings.';

  @override
  String get ok => 'OK';

  @override
  String get activeTimer => 'ACTIVE TIMER';

  @override
  String get motivation => 'Motivation';

  @override
  String get customize => 'Customize';

  @override
  String get appTheme => 'App Theme';

  @override
  String get themeSubtitle => 'Choose the theme that reflects you best';

  @override
  String themeUnlocked(String themeName) {
    return '\"$themeName\" theme unlocked permanently!';
  }

  @override
  String get adNotReady =>
      'Ad is not ready yet. Please try again in a few seconds.';

  @override
  String get watchAdFully =>
      'You must watch the entire video to unlock the theme.';

  @override
  String get locked => 'LOCKED';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get editExamPreferences => 'Edit Exam Preferences';

  @override
  String get changeTrackedExams => 'Change the exams you track';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get widgetStudioSubtitle => 'Customize widget appearance';

  @override
  String get selectExam => 'SELECT EXAM';

  @override
  String get selectExamSubtitle =>
      'You can select the exams you want to track.';

  @override
  String get continueButton => 'CONTINUE';

  @override
  String get maxExamLimit => 'Maximum Exam Limit';

  @override
  String get watchAdToUnlock =>
      'You can watch an ad to unlock a new slot and track more exams.';

  @override
  String get watchAdAndUnlock => 'Watch Ad & Unlock';

  @override
  String get unlockNewSlotTitle => 'Unlock New Timer Slot';

  @override
  String get unlockNewSlotDesc =>
      'You have reached your active exam timer capacity. Use the option below to add more exams.';

  @override
  String get watchAdEarnSlot => 'Watch 1 Video, Earn +1 Timer Slot';

  @override
  String get slotEarnedSuccess => 'Successfully earned +1 Timer Slot!';

  @override
  String get adNotReadyWait =>
      'Ad is not ready yet. Please wait a bit and try again.';

  @override
  String get watchAdFullyForSlot =>
      'You must watch the video to the end to unlock the slot.';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get editExamDates => 'Edit Exam Dates';

  @override
  String get editExamDatesSubtitle => 'Manually update exam dates';

  @override
  String get resetAllDates => 'Reset All Dates';

  @override
  String get resetDatesConfirm =>
      'All exam dates will be reset to defaults. Are you sure?';

  @override
  String get reset => 'Reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get dateUpdated => 'Date updated';

  @override
  String get datesResetSuccess => 'All dates have been reset';

  @override
  String get edited => 'edited';

  @override
  String get selectDate => 'Select Date';

  @override
  String get addCustomExam => 'Add Custom Exam';

  @override
  String get addCustomExamSubtitle => 'Add and track your own exam';

  @override
  String get examName => 'Exam Name';

  @override
  String get examCode => 'Exam Code (optional)';

  @override
  String get examNameRequired => 'Exam name cannot be empty';

  @override
  String get examDateRequired => 'Exam date must be selected';

  @override
  String get examAdded => 'Exam added';

  @override
  String get deleteExam => 'Delete Exam';

  @override
  String get deleteExamConfirm =>
      'This exam will be permanently deleted. Are you sure?';

  @override
  String get delete => 'Delete';

  @override
  String get customExamLabel => 'CUSTOM';

  @override
  String get mockExams => 'My Exams';

  @override
  String get allFilter => 'All';

  @override
  String get customExamFilter => 'Custom Exam';

  @override
  String get addMockExam => 'Add Mock Exam';

  @override
  String get selectExamType => 'Select Exam Type';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get netScore => 'Net';

  @override
  String get totalNet => 'Total Net';

  @override
  String get save => 'Save';

  @override
  String get validationExceeded =>
      'Correct + Incorrect cannot exceed question count';

  @override
  String get mockExamSaved => 'Mock exam saved';

  @override
  String get expandChart => 'Expand Your Chart';

  @override
  String get watchAdForSlots =>
      'Watch a short video to unlock +5 new exam slots.';

  @override
  String get slotsUnlocked => '+5 exam slots unlocked!';

  @override
  String get noMockExams => 'No mock exams added yet';

  @override
  String get mockExamDeleted => 'Mock exam deleted';

  @override
  String get changeTheme => 'Change Theme';

  @override
  String get changeThemeSubtitle => 'Customize app theme';

  @override
  String get totalCorrect => 'Total Correct';

  @override
  String get totalIncorrect => 'Total Incorrect';
}
