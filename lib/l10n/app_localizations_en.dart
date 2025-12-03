// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MediNote';

  @override
  String get home => 'Home';

  @override
  String get patients => 'Patients';

  @override
  String get sessions => 'Sessions';

  @override
  String get settings => 'Settings';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get patientName => 'Patient Name';

  @override
  String get patientEmail => 'Email';

  @override
  String get pronouns => 'Pronouns';

  @override
  String get background => 'Background';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get familyHistory => 'Family History';

  @override
  String get socialHistory => 'Social History';

  @override
  String get previousTreatment => 'Previous Treatment';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get pauseRecording => 'Pause Recording';

  @override
  String get resumeRecording => 'Resume Recording';

  @override
  String get recording => 'Recording';

  @override
  String get paused => 'Paused';

  @override
  String get uploadStatus => 'Upload Status';

  @override
  String chunksUploaded(int count) {
    return '$count chunks uploaded';
  }

  @override
  String get networkOffline => 'Offline';

  @override
  String get networkOnline => 'Online';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get sessionTitle => 'Session Title';

  @override
  String get duration => 'Duration';

  @override
  String get transcript => 'Transcript';

  @override
  String get liveTranscription => 'Live Transcription';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get microphonePermission =>
      'Microphone permission is required to record audio';

  @override
  String get cameraPermission => 'Camera permission is required to take photos';

  @override
  String get notificationPermission =>
      'Notification permission is required for background recording';

  @override
  String get notificationPermissionDenied =>
      'Background recording requires notification permission. Please enable it in settings to continue.';

  @override
  String get grant => 'Grant Permission';

  @override
  String get sessionRecovery => 'Session Recovery';

  @override
  String get sessionRecoveryMessage =>
      'An interrupted recording session was found. Would you like to resume?';

  @override
  String get resume => 'Resume';

  @override
  String get discard => 'Discard';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get noPatients => 'No patients found';

  @override
  String get noSessions => 'No sessions found';

  @override
  String get addFirstPatient => 'Add your first patient to get started';

  @override
  String get microphoneGain => 'Microphone Gain';

  @override
  String get ready => 'Ready';

  @override
  String get confirmStopMessage => 'Are you sure you want to stop recording?';

  @override
  String get stop => 'Stop';

  @override
  String get recordingStarted => 'Recording started';

  @override
  String get appSubtitle => 'Medical Transcription App';

  @override
  String get demoStatus => 'Demo Status';

  @override
  String get completedFeatures => 'Completed Features';

  @override
  String get nextSteps => 'Next Steps';

  @override
  String get featureJwtAuth => 'JWT Auth';

  @override
  String get featurePatientMgmt => 'Patient Mgmt';

  @override
  String get featureSessionRec => 'Session Rec';

  @override
  String get featureSecureUpload => 'Secure Upload';

  @override
  String get featureTemplates => 'Templates';

  @override
  String get featureDocker => 'Docker';

  @override
  String get statusBackendApi => 'Backend API';

  @override
  String get statusMongoDb => 'MongoDB';

  @override
  String get statusLocalization => 'Localization';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get viewRecordings => 'View Recordings';

  @override
  String get noRecordingsYet => 'No recordings yet';

  @override
  String get recordingsWillAppear =>
      'Recordings will appear here after\nyou create them';

  @override
  String get noAudioAvailable => 'No audio available';

  @override
  String get chunks => 'chunks';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started';

  @override
  String get signIn => 'Sign In';

  @override
  String get recordings => 'Recordings';

  @override
  String get errorLoadingRecordings => 'Error loading recordings';

  @override
  String get retry => 'Retry';

  @override
  String get completed => 'Completed';

  @override
  String get processing => 'Processing';

  @override
  String get failed => 'Failed';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get speed => 'Speed';
}
