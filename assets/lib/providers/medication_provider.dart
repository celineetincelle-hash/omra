import 'package:flutter/material.dart';
import 'package:omra_track/features/medication/medication_service.dart';
import 'package:omra_track/models/medication_model.dart';

class MedicationProvider extends ChangeNotifier {
  final MedicationService _medicationService = MedicationService();
  List<Medication> _medications = [];
  bool _isInitialized = false;

  List<Medication> get medications => _medications;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _medicationService.initialize();
    _medications = _medicationService.getAllMedications();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    await _medicationService.addMedication(medication);
    _medications = _medicationService.getAllMedications();
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication) async {
    await _medicationService.updateMedication(medication);
    _medications = _medicationService.getAllMedications();
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    await _medicationService.deleteMedication(id);
    _medications = _medicationService.getAllMedications();
    notifyListeners();
  }

  Medication? getMedication(String id) {
    return _medicationService.getMedication(id);
  }

  List<Medication> getActiveMedications() {
    return _medications.where((med) => med.isActive).toList();
  }
}
