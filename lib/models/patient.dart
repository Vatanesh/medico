class Patient {
  final String id;
  final String name;
  final String? email;
  final String? pronouns;
  final String? background;
  final String? medicalHistory;
  final String? familyHistory;
  final String? socialHistory;
  final String? previousTreatment;

  Patient({
    required this.id,
    required this.name,
    this.email,
    this.pronouns,
    this.background,
    this.medicalHistory,
    this.familyHistory,
    this.socialHistory,
    this.previousTreatment,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      pronouns: json['pronouns'],
      background: json['background'],
      medicalHistory: json['medical_history'],
      familyHistory: json['family_history'],
      socialHistory: json['social_history'],
      previousTreatment: json['previous_treatment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pronouns': pronouns,
      'background': background,
      'medical_history': medicalHistory,
      'family_history': familyHistory,
      'social_history': socialHistory,
      'previous_treatment': previousTreatment,
    };
  }
}
