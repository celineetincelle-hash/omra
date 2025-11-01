import 'package:flutter/material.dart';
import 'package:omra_track/models/user_model.dart';

// Mock data for a user
final UserModel _mockUser = UserModel(
  id: 'mock_user_id',
  name: 'Mock User',
  email: 'mock@example.com',
  phone: '0123456789',
  groupId: 'mock_group_id',
  latitude: 0.0,
  longitude: 0.0,
);

class AuthProvider extends ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Removed
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Removed
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Mock implementation for checkAuthStatus
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    // Simulating a successful check and loading a mock user
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = _mockUser; // Automatically log in with mock user

    _isLoading = false;
    notifyListeners();
  }

  // Mock implementation for sign in
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mock: any non-empty email/password works
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = _mockUser.copyWith(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Mock implementation for sign up
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mock: assume successful creation
    final UserModel newUser = _mockUser.copyWith(
      id: 'new_mock_id_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      groupId: '',
    );

    _currentUser = newUser;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Mock implementation for sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    notifyListeners();
  }

  // Mock implementation for loading user data (no-op as user is already in-memory)
  // The original function was private, so we keep it that way.
  // ignore: unused_element
  Future<void> _loadUserData(String userId) async {
    // In a real app, this would load data from a non-Firebase backend.
    // For this task, we assume the user is loaded upon sign-in/checkAuthStatus.
  }

  // Mock implementation for updating user location
  Future<bool> updateUserLocation(double latitude, double longitude) async {
    if (_currentUser == null) return false;
    
    await Future.delayed(const Duration(milliseconds: 100));

    _currentUser = _currentUser!.copyWith(
      latitude: latitude,
      longitude: longitude,
      lastLocationUpdate: DateTime.now(),
    );
    
    notifyListeners();
    return true;
  }

  // Mock implementation for joining a group
  Future<bool> joinGroup(String groupCode) async {
    if (_currentUser == null) return false;

    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mock: assume successful join if groupCode is not empty
    if (groupCode.isNotEmpty) {
      _currentUser = _currentUser!.copyWith(groupId: 'mock_group_id_joined');
      notifyListeners();
      return true;
    }
    
    return false;
  }
}
