class ApiEndpoints {
  // Base URLs - UPDATE THESE when deployed
  static const String baseUrl = 'https://medico-zbsf.onrender.com';
  static const String apiBaseUrl = '$baseUrl/v1';
  
  // Authentication
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String getUserByEmail = '$baseUrl/users/asd3fd2faec';
  
  // Patient Management
  static const String patients = '$apiBaseUrl/patients';
  static const String addPatient = '$apiBaseUrl/add-patient-ext';
  static String patientDetails(String patientId) => '$apiBaseUrl/patient-details/$patientId';
  
  // Session Management
  static const String uploadSession = '$apiBaseUrl/upload-session';
  static const String getPresignedUrl = '$apiBaseUrl/get-presigned-url';
  static const String notifyChunkUploaded = '$apiBaseUrl/notify-chunk-uploaded';
  static String fetchSessionByPatient(String patientId) => '$apiBaseUrl/fetch-session-by-patient/$patientId';
  static const String allSessions = '$apiBaseUrl/all-session';
  
  // Template Management
  static const String fetchDefaultTemplate = '$apiBaseUrl/fetch-default-template-ext';
  
  // Storage
  static String storageUpload(String token) => '$baseUrl/v1/storage/upload/$token';
  static String storagePublic(String sessionId, String filename) => '$baseUrl/v1/storage/public/$sessionId/$filename';
}

class AppConstants {
  static const String appName = 'MediNote';
  
  // Chunk configuration
  static const Duration chunkDuration = Duration(seconds: 15);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Audio configuration
  static const int sampleRate = 44100;
  static const String audioMimeType = 'audio/wav';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Hive box names
  static const String chunkQueueBox = 'chunk_queue';
  static const String sessionRecoveryBox = 'session_recovery';
}
