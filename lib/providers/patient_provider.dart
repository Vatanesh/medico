import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api/api_service.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _error;

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPatients(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPatients(userId);
      _patients = response.map((json) => Patient.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _patients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await _apiService.addPatient(patientData);
      _patients.add(Patient.fromJson(response));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Patient> getPatientDetails(String patientId) async {
    try {
      final response = await _apiService.getPatientDetails(patientId);
      return Patient.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
