// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मेडीनोट';

  @override
  String get home => 'होम';

  @override
  String get patients => 'मरीज़';

  @override
  String get sessions => 'सत्र';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get addPatient => 'नया मरीज़';

  @override
  String get patientName => 'मरीज़ का नाम';

  @override
  String get patientEmail => 'ईमेल';

  @override
  String get pronouns => 'सर्वनाम';

  @override
  String get background => 'पृष्ठभूमि';

  @override
  String get medicalHistory => 'चिकित्सा इतिहास';

  @override
  String get familyHistory => 'पारिवारिक इतिहास';

  @override
  String get socialHistory => 'सामाजिक इतिहास';

  @override
  String get previousTreatment => 'पिछला उपचार';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get startRecording => 'रिकॉर्डिंग शुरू करें';

  @override
  String get stopRecording => 'रिकॉर्डिंग बंद करें';

  @override
  String get pauseRecording => 'रिकॉर्डिंग रोकें';

  @override
  String get resumeRecording => 'रिकॉर्डिंग फिर से शुरू करें';

  @override
  String get recording => 'रिकॉर्डिंग';

  @override
  String get paused => 'रुका हुआ';

  @override
  String get uploadStatus => 'अपलोड स्थिति';

  @override
  String chunksUploaded(int count) {
    return '$count chunks अपलोड किए गए';
  }

  @override
  String get networkOffline => 'ऑफ़लाइन';

  @override
  String get networkOnline => 'ऑनलाइन';

  @override
  String get selectTemplate => 'टेम्पलेट चुनें';

  @override
  String get sessionTitle => 'सत्र शीर्षक';

  @override
  String get duration => 'अवधि';

  @override
  String get transcript => 'प्रतिलेख';

  @override
  String get liveTranscription => 'लाइव ट्रांसक्रिप्शन';

  @override
  String get theme => 'थीम';

  @override
  String get language => 'भाषा';

  @override
  String get light => 'हल्का';

  @override
  String get dark => 'गहरा';

  @override
  String get system => 'सिस्टम';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get microphonePermission =>
      'ऑडियो रिकॉर्ड करने के लिए माइक्रोफ़ोन अनुमति आवश्यक है';

  @override
  String get cameraPermission => 'फ़ोटो लेने के लिए कैमरा अनुमति आवश्यक है';

  @override
  String get notificationPermission =>
      'बैकग्राउंड रिकॉर्डिंग के लिए नोटिफिकेशन अनुमति आवश्यक है';

  @override
  String get notificationPermissionDenied =>
      'बैकग्राउंड रिकॉर्डिंग के लिए नोटिफिकेशन अनुमति आवश्यक है। जारी रखने के लिए कृपया इसे सेटिंग्स में सक्षम करें।';

  @override
  String get grant => 'अनुमति दें';

  @override
  String get sessionRecovery => 'सत्र पुनर्प्राप्ति';

  @override
  String get sessionRecoveryMessage =>
      'एक बाधित रिकॉर्डिंग सत्र मिला। क्या आप फिर से शुरू करना चाहेंगे?';

  @override
  String get resume => 'फिर से शुरू करें';

  @override
  String get discard => 'छोड़ दें';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get noPatients => 'कोई मरीज़ नहीं मिला';

  @override
  String get noSessions => 'कोई सत्र नहीं मिला';

  @override
  String get addFirstPatient => 'शुरू करने के लिए अपना पहला मरीज़ जोड़ें';

  @override
  String get microphoneGain => 'माइक्रोफ़ोन गेन';

  @override
  String get ready => 'तैयार';

  @override
  String get confirmStopMessage => 'क्या आप वाकई रिकॉर्डिंग रोकना चाहते हैं?';

  @override
  String get stop => 'रोकें';

  @override
  String get recordingStarted => 'रिकॉर्डिंग शुरू हो गई';

  @override
  String get appSubtitle => 'मेडिकल ट्रांसक्रिप्शन ऐप';

  @override
  String get demoStatus => 'डेमो स्थिति';

  @override
  String get completedFeatures => 'पूर्ण सुविधाएँ';

  @override
  String get nextSteps => 'अगले चरण';

  @override
  String get featureJwtAuth => 'JWT प्रमाणीकरण';

  @override
  String get featurePatientMgmt => 'मरीज़ प्रबंधन';

  @override
  String get featureSessionRec => 'सत्र रिकॉर्डिंग';

  @override
  String get featureSecureUpload => 'सुरक्षित अपलोड';

  @override
  String get featureTemplates => 'टेम्पलेट्स';

  @override
  String get featureDocker => 'डॉकर';

  @override
  String get statusBackendApi => 'बैकएंड एपीआई';

  @override
  String get statusMongoDb => 'मोंगोडीबी';

  @override
  String get statusLocalization => 'स्थानीयकरण';
}
