import 'package:flutter/material.dart';
import 'package:omra_track/models/group_model.dart';
import 'package:omra_track/models/user_model.dart';
import 'dart:math';

// Mock data
final UserModel _mockAdmin = UserModel(
  id: 'mock_admin_id',
  name: 'Admin Mock',
  email: 'admin@mock.com',
  phone: '111222333',
  groupId: 'mock_group_id',
  isAdmin: true,
);

final UserModel _mockMember = UserModel(
  id: 'mock_member_id',
  name: 'Member Mock',
  email: 'member@mock.com',
  phone: '444555666',
  groupId: 'mock_group_id',
  isAdmin: false,
);

final GroupModel _mockGroup = GroupModel(
  id: 'mock_group_id',
  name: 'Mock Family Group',
  description: 'A mock group for testing.',
  adminId: _mockAdmin.id,
  qrCode: 'MOCK1234',
  memberIds: [_mockAdmin.id, _mockMember.id],
  createdAt: DateTime.now(),
);

class GroupProvider extends ChangeNotifier {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Removed
  
  GroupModel? _currentGroup;
  List<UserModel> _groupMembers = [];
  List<GroupModel> _groups = [];
  UserModel? _groupAdmin;
  bool _isLoading = false;

  GroupModel? get currentGroup => _currentGroup;
  List<UserModel> get groupMembers => _groupMembers;
  List<GroupModel> get groups => _groups;
  UserModel? get groupAdmin => _groupAdmin;
  bool get isLoading => _isLoading;

  // Mock implementation for loadGroupData
  Future<void> loadGroupData(String groupId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (groupId == _mockGroup.id) {
      _currentGroup = _mockGroup;
      await _loadGroupMembers();
      await _loadGroupAdmin();
    } else {
      _currentGroup = null;
      _groupMembers = [];
      _groupAdmin = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mock implementation for _loadGroupMembers
  Future<void> _loadGroupMembers() async {
    if (_currentGroup == null) return;

    // In a real app, this would fetch from a non-Firebase backend.
    // Here, we use mock data.
    _groupMembers = [_mockAdmin, _mockMember];
  }

  // Mock implementation for _loadGroupAdmin
  Future<void> _loadGroupAdmin() async {
    if (_currentGroup == null) return;

    // In a real app, this would fetch from a non-Firebase backend.
    // Here, we use mock data.
    _groupAdmin = _mockAdmin;
  }

  // Mock implementation for getGroupMembersStream
  Stream<List<UserModel>> getGroupMembersStream(String groupId) async* {
    // Mock stream: yield the current mock members once
    if (groupId == _mockGroup.id) {
      yield [_mockAdmin, _mockMember];
    } else {
      yield [];
    }
  }

  // Mock implementation for createGroup
  Future<String> createGroup({
    required String name,
    required String description,
    required String adminId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate successful creation
    final String newGroupId = 'new_mock_group_${DateTime.now().millisecondsSinceEpoch}';
    
    // Update mock state for demonstration
    _currentGroup = _mockGroup.copyWith(
      id: newGroupId,
      name: name,
      description: description,
      adminId: adminId,
      memberIds: [adminId],
    );
    _groupAdmin = _mockAdmin.copyWith(id: adminId, groupId: newGroupId, isAdmin: true);
    _groupMembers = [_groupAdmin!];

    notifyListeners();
    return newGroupId;
  }

  // Mock implementation for addMemberToGroup
  Future<bool> addMemberToGroup(String groupId, String userId) async {
    if (_currentGroup == null || groupId != _currentGroup!.id) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate successful addition
    if (!_currentGroup!.memberIds.contains(userId)) {
      _currentGroup = _currentGroup!.copyWith(
        memberIds: [..._currentGroup!.memberIds, userId],
      );
      // Re-add mock member to list for simulation
      if (userId == _mockMember.id && !_groupMembers.contains(_mockMember)) {
        _groupMembers.add(_mockMember);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mock implementation for joinGroupWithCode
  Future<bool> joinGroupWithCode(String groupCode, String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Simulation de la logique de jonction de groupe
    // Dans une application réelle, cela impliquerait un appel à une API backend
    // pour vérifier le code et associer l'utilisateur au groupe.
    if (groupCode.toUpperCase() == _mockGroup.qrCode) {
      // Simuler l'ajout de l'utilisateur au groupe
      final success = await addMemberToGroup(_mockGroup.id, userId);
      
      if (success) {
        // Charger les données du groupe après la jonction
        await loadGroupData(_mockGroup.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  // Mock implementation for removeMemberFromGroup
  Future<bool> removeMemberFromGroup(String groupId, String userId) async {
    if (_currentGroup == null || groupId != _currentGroup!.id) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate successful removal
    if (_currentGroup!.memberIds.contains(userId)) {
      _currentGroup = _currentGroup!.copyWith(
        memberIds: _currentGroup!.memberIds.where((id) => id != userId).toList(),
      );
      _groupMembers.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    }
    return false;
  }

  String _generateQRCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnitAt(random.nextInt(chars.length))
    ));
  }

  void clearGroupData() {
    _currentGroup = null;
    _groupMembers.clear();
    _groupAdmin = null;
    notifyListeners();
  }
}
