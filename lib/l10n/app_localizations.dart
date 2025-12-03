import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('hi'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MediNote'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @patientEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get patientEmail;

  /// No description provided for @pronouns.
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get pronouns;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @familyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get familyHistory;

  /// No description provided for @socialHistory.
  ///
  /// In en, this message translates to:
  /// **'Social History'**
  String get socialHistory;

  /// No description provided for @previousTreatment.
  ///
  /// In en, this message translates to:
  /// **'Previous Treatment'**
  String get previousTreatment;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @pauseRecording.
  ///
  /// In en, this message translates to:
  /// **'Pause Recording'**
  String get pauseRecording;

  /// No description provided for @resumeRecording.
  ///
  /// In en, this message translates to:
  /// **'Resume Recording'**
  String get resumeRecording;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @uploadStatus.
  ///
  /// In en, this message translates to:
  /// **'Upload Status'**
  String get uploadStatus;

  /// Number of audio chunks uploaded
  ///
  /// In en, this message translates to:
  /// **'{count} chunks uploaded'**
  String chunksUploaded(int count);

  /// No description provided for @networkOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get networkOffline;

  /// No description provided for @networkOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get networkOnline;

  /// No description provided for @selectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select Template'**
  String get selectTemplate;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Title'**
  String get sessionTitle;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @liveTranscription.
  ///
  /// In en, this message translates to:
  /// **'Live Transcription'**
  String get liveTranscription;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @microphonePermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record audio'**
  String get microphonePermission;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get cameraPermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for background recording'**
  String get notificationPermission;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Background recording requires notification permission. Please enable it in settings to continue.'**
  String get notificationPermissionDenied;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grant;

  /// No description provided for @sessionRecovery.
  ///
  /// In en, this message translates to:
  /// **'Session Recovery'**
  String get sessionRecovery;

  /// No description provided for @sessionRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'An interrupted recording session was found. Would you like to resume?'**
  String get sessionRecoveryMessage;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatients;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions found'**
  String get noSessions;

  /// No description provided for @addFirstPatient.
  ///
  /// In en, this message translates to:
  /// **'Add your first patient to get started'**
  String get addFirstPatient;

  /// No description provided for @microphoneGain.
  ///
  /// In en, this message translates to:
  /// **'Microphone Gain'**
  String get microphoneGain;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @confirmStopMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop recording?'**
  String get confirmStopMessage;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @recordingStarted.
  ///
  /// In en, this message translates to:
  /// **'Recording started'**
  String get recordingStarted;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Transcription App'**
  String get appSubtitle;

  /// No description provided for @demoStatus.
  ///
  /// In en, this message translates to:
  /// **'Demo Status'**
  String get demoStatus;

  /// No description provided for @completedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Completed Features'**
  String get completedFeatures;

  /// No description provided for @nextSteps.
  ///
  /// In en, this message translates to:
  /// **'Next Steps'**
  String get nextSteps;

  /// No description provided for @featureJwtAuth.
  ///
  /// In en, this message translates to:
  /// **'JWT Auth'**
  String get featureJwtAuth;

  /// No description provided for @featurePatientMgmt.
  ///
  /// In en, this message translates to:
  /// **'Patient Mgmt'**
  String get featurePatientMgmt;

  /// No description provided for @featureSessionRec.
  ///
  /// In en, this message translates to:
  /// **'Session Rec'**
  String get featureSessionRec;

  /// No description provided for @featureSecureUpload.
  ///
  /// In en, this message translates to:
  /// **'Secure Upload'**
  String get featureSecureUpload;

  /// No description provided for @featureTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get featureTemplates;

  /// No description provided for @featureDocker.
  ///
  /// In en, this message translates to:
  /// **'Docker'**
  String get featureDocker;

  /// No description provided for @statusBackendApi.
  ///
  /// In en, this message translates to:
  /// **'Backend API'**
  String get statusBackendApi;

  /// No description provided for @statusMongoDb.
  ///
  /// In en, this message translates to:
  /// **'MongoDB'**
  String get statusMongoDb;

  /// No description provided for @statusLocalization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get statusLocalization;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
