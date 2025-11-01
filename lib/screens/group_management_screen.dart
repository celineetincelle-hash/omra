import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../features/bluetooth/group_bluetooth_service.dart';
import '../features/bluetooth/group_types.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final GroupBluetoothService _groupService = GroupBluetoothService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  String? _groupId;
  bool _isLeader = false;
  List<GroupMember> _members = [];
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    await _groupService.initialize();
    
    _groupService.eventStream.listen((event) {
      if (mounted) {
        setState(() {
          switch (event.type) {
            case GroupEventType.groupCreated:
            case GroupEventType.groupJoined:
            case GroupEventType.groupRestored:
              _groupId = _groupService.currentGroupId;
              _isLeader = _groupService.isLeader;
              _errorMessage = '';
              break;
            case GroupEventType.groupLeft:
              _groupId = null;
              _isLeader = false;
              _members.clear();
              break;
            case GroupEventType.permissionDenied:
            case GroupEventType.error:
              _errorMessage = event.data;
              break;
            default:
              break;
          }
        });
      }
    });
    
    _groupService.membersStream.listen((members) {
      if (mounted) {
        setState(() {
          _members = members;
        });
      }
    });
    
    if (mounted) {
      setState(() {
        _groupId = _groupService.currentGroupId;
        _isLeader = _groupService.isLeader;
      });
    }
  }
  
  Future<void> _createGroup() async {
    setState(() => _isLoading = true);
    try {
      final groupId = await _groupService.createGroup();
      if (mounted) {
        setState(() {
          _groupId = groupId;
          _isLeader = true;
          _errorMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('group_created'))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _joinGroupWithCode() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = tr('invalid_code'));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _groupService.joinGroup(_codeController.text.trim());
      if (mounted) {
        setState(() {
          _groupId = _codeController.text.trim();
          _isLeader = false;
          _errorMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('group_joined'))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _leaveGroup() async {
    await _groupService.leaveGroup();
    if (mounted) {
      setState(() {
        _groupId = null;
        _isLeader = false;
        _members.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('group_left'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('group_tracking')),
        actions: _groupId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _leaveGroup,
                  tooltip: tr('leave_group'),
                ),
              ]
            : null,
      ),
      body: _groupId == null ? _buildJoinOrCreateScreen() : _buildGroupManagementScreen(),
    );
  }

  Widget _buildJoinOrCreateScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createGroup,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.group_add),
              label: Text(tr('create_group')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(tr('or').toUpperCase()),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              tr('join_group'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: tr('group_code'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => context.go('/scan_qr'),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _joinGroupWithCode,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.login),
              label: Text(tr('join_group')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupManagementScreen() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _isLeader ? Icons.star : Icons.person,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isLeader ? tr('you_are_leader') : tr('you_are_member'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${tr('group_id')}: ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _groupId!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _groupId!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr('copied'))),
                      );
                    },
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLeader)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  tr('invite_members'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _groupId!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tr('group_members')} (${_members.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _members.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.group, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _isLeader ? tr('waiting_for_members') : tr('searching_group'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    member.isLeader ? Icons.star : Icons.person,
                                    color: member.isLeader ? Colors.amber : null,
                                  ),
                                ),
                                title: Text(member.name),
                                subtitle: Text(
                                  member.isConnected ? tr('connected') : tr('disconnected'),
                                ),
                                trailing: Icon(
                                  member.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                                  color: member.isConnected ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _groupService.dispose();
    super.dispose();
  }
}
