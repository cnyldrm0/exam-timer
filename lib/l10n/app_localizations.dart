import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Timer'**
  String get appTitle;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mainMenu;

  /// No description provided for @widget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get widget;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @widgetStudio.
  ///
  /// In en, this message translates to:
  /// **'WIDGET STUDIO'**
  String get widgetStudio;

  /// No description provided for @applyAndAdd.
  ///
  /// In en, this message translates to:
  /// **'APPLY AND ADD'**
  String get applyAndAdd;

  /// No description provided for @howToAddWidget.
  ///
  /// In en, this message translates to:
  /// **'How to Add a Widget?'**
  String get howToAddWidget;

  /// No description provided for @tutorialStep1.
  ///
  /// In en, this message translates to:
  /// **'Long press an empty space on your home screen.'**
  String get tutorialStep1;

  /// No description provided for @tutorialStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Widgets\' or \'Tools\'.'**
  String get tutorialStep2;

  /// No description provided for @tutorialStep3.
  ///
  /// In en, this message translates to:
  /// **'Find the \'Exam Timer\' app.'**
  String get tutorialStep3;

  /// No description provided for @tutorialStep4.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop the widget onto your home screen.'**
  String get tutorialStep4;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'UNDERSTOOD'**
  String get understood;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get style;

  /// No description provided for @whichExamToShow.
  ///
  /// In en, this message translates to:
  /// **'Which Exam to Show?'**
  String get whichExamToShow;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @blur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get blur;

  /// No description provided for @widgetOptimizedInfo.
  ///
  /// In en, this message translates to:
  /// **'Note: Widget is optimized to show Day and Hour on the home screen.'**
  String get widgetOptimizedInfo;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get hours;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'MINS'**
  String get mins;

  /// No description provided for @secs.
  ///
  /// In en, this message translates to:
  /// **'SECS'**
  String get secs;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remaining;

  /// No description provided for @examCompleted.
  ///
  /// In en, this message translates to:
  /// **'EXAM COMPLETED'**
  String get examCompleted;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'DAYS LEFT'**
  String get daysLeft;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get welcome;

  /// No description provided for @motivationTitle.
  ///
  /// In en, this message translates to:
  /// **'MOTIVATION OF THE DAY'**
  String get motivationTitle;

  /// No description provided for @refreshQuote.
  ///
  /// In en, this message translates to:
  /// **'Refresh Quote'**
  String get refreshQuote;

  /// No description provided for @timeLeftToExams.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining for Exams'**
  String get timeLeftToExams;

  /// No description provided for @noExamSelected.
  ///
  /// In en, this message translates to:
  /// **'No Exam Selected Yet'**
  String get noExamSelected;

  /// No description provided for @addExam.
  ///
  /// In en, this message translates to:
  /// **'ADD EXAM'**
  String get addExam;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop Tracking Exam'**
  String get stopTracking;

  /// No description provided for @trackingStoppedMessage.
  ///
  /// In en, this message translates to:
  /// **'Exam tracking stopped. You can edit your exam preferences in Settings.'**
  String get trackingStoppedMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @activeTimer.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TIMER'**
  String get activeTimer;

  /// No description provided for @motivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get motivation;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the theme that reflects you best'**
  String get themeSubtitle;

  /// No description provided for @themeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'\"{themeName}\" theme unlocked permanently!'**
  String themeUnlocked(String themeName);

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad is not ready yet. Please try again in a few seconds.'**
  String get adNotReady;

  /// No description provided for @watchAdFully.
  ///
  /// In en, this message translates to:
  /// **'You must watch the entire video to unlock the theme.'**
  String get watchAdFully;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @editExamPreferences.
  ///
  /// In en, this message translates to:
  /// **'Edit Exam Preferences'**
  String get editExamPreferences;

  /// No description provided for @changeTrackedExams.
  ///
  /// In en, this message translates to:
  /// **'Change the exams you track'**
  String get changeTrackedExams;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @widgetStudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize widget appearance'**
  String get widgetStudioSubtitle;

  /// No description provided for @selectExam.
  ///
  /// In en, this message translates to:
  /// **'SELECT EXAM'**
  String get selectExam;

  /// No description provided for @selectExamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can select the exams you want to track.'**
  String get selectExamSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @maxExamLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum Exam Limit'**
  String get maxExamLimit;

  /// No description provided for @watchAdToUnlock.
  ///
  /// In en, this message translates to:
  /// **'You can watch an ad to unlock a new slot and track more exams.'**
  String get watchAdToUnlock;

  /// No description provided for @watchAdAndUnlock.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad & Unlock'**
  String get watchAdAndUnlock;

  /// No description provided for @unlockNewSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock New Timer Slot'**
  String get unlockNewSlotTitle;

  /// No description provided for @unlockNewSlotDesc.
  ///
  /// In en, this message translates to:
  /// **'You have reached your active exam timer capacity. Use the option below to add more exams.'**
  String get unlockNewSlotDesc;

  /// No description provided for @watchAdEarnSlot.
  ///
  /// In en, this message translates to:
  /// **'Watch 1 Video, Earn +1 Timer Slot'**
  String get watchAdEarnSlot;

  /// No description provided for @slotEarnedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully earned +1 Timer Slot!'**
  String get slotEarnedSuccess;

  /// No description provided for @adNotReadyWait.
  ///
  /// In en, this message translates to:
  /// **'Ad is not ready yet. Please wait a bit and try again.'**
  String get adNotReadyWait;

  /// No description provided for @watchAdFullyForSlot.
  ///
  /// In en, this message translates to:
  /// **'You must watch the video to the end to unlock the slot.'**
  String get watchAdFullyForSlot;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @editExamDates.
  ///
  /// In en, this message translates to:
  /// **'Edit Exam Dates'**
  String get editExamDates;

  /// No description provided for @editExamDatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manually update exam dates'**
  String get editExamDatesSubtitle;

  /// No description provided for @resetAllDates.
  ///
  /// In en, this message translates to:
  /// **'Reset All Dates'**
  String get resetAllDates;

  /// No description provided for @resetDatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'All exam dates will be reset to defaults. Are you sure?'**
  String get resetDatesConfirm;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @dateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date updated'**
  String get dateUpdated;

  /// No description provided for @datesResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All dates have been reset'**
  String get datesResetSuccess;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @addCustomExam.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Exam'**
  String get addCustomExam;

  /// No description provided for @addCustomExamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and track your own exam'**
  String get addCustomExamSubtitle;

  /// No description provided for @examName.
  ///
  /// In en, this message translates to:
  /// **'Exam Name'**
  String get examName;

  /// No description provided for @examCode.
  ///
  /// In en, this message translates to:
  /// **'Exam Code (optional)'**
  String get examCode;

  /// No description provided for @examNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Exam name cannot be empty'**
  String get examNameRequired;

  /// No description provided for @examDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Exam date must be selected'**
  String get examDateRequired;

  /// No description provided for @examAdded.
  ///
  /// In en, this message translates to:
  /// **'Exam added'**
  String get examAdded;

  /// No description provided for @deleteExam.
  ///
  /// In en, this message translates to:
  /// **'Delete Exam'**
  String get deleteExam;

  /// No description provided for @deleteExamConfirm.
  ///
  /// In en, this message translates to:
  /// **'This exam will be permanently deleted. Are you sure?'**
  String get deleteExamConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customExamLabel.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get customExamLabel;

  /// No description provided for @mockExams.
  ///
  /// In en, this message translates to:
  /// **'My Exams'**
  String get mockExams;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @customExamFilter.
  ///
  /// In en, this message translates to:
  /// **'Custom Exam'**
  String get customExamFilter;

  /// No description provided for @addMockExam.
  ///
  /// In en, this message translates to:
  /// **'Add Mock Exam'**
  String get addMockExam;

  /// No description provided for @selectExamType.
  ///
  /// In en, this message translates to:
  /// **'Select Exam Type'**
  String get selectExamType;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @netScore.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netScore;

  /// No description provided for @totalNet.
  ///
  /// In en, this message translates to:
  /// **'Total Net'**
  String get totalNet;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @validationExceeded.
  ///
  /// In en, this message translates to:
  /// **'Correct + Incorrect cannot exceed question count'**
  String get validationExceeded;

  /// No description provided for @mockExamSaved.
  ///
  /// In en, this message translates to:
  /// **'Mock exam saved'**
  String get mockExamSaved;

  /// No description provided for @expandChart.
  ///
  /// In en, this message translates to:
  /// **'Expand Your Chart'**
  String get expandChart;

  /// No description provided for @watchAdForSlots.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video to unlock +5 new exam slots.'**
  String get watchAdForSlots;

  /// No description provided for @slotsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'+5 exam slots unlocked!'**
  String get slotsUnlocked;

  /// No description provided for @noMockExams.
  ///
  /// In en, this message translates to:
  /// **'No mock exams added yet'**
  String get noMockExams;

  /// No description provided for @mockExamDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mock exam deleted'**
  String get mockExamDeleted;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeTheme;

  /// No description provided for @changeThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize app theme'**
  String get changeThemeSubtitle;

  /// No description provided for @totalCorrect.
  ///
  /// In en, this message translates to:
  /// **'Total Correct'**
  String get totalCorrect;

  /// No description provided for @totalIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Total Incorrect'**
  String get totalIncorrect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
