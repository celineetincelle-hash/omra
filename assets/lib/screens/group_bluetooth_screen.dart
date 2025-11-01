import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GroupBluetoothScreen extends StatelessWidget {
  const GroupBluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('bluetooth_members')),
      ),
      body: const Center(
        child: Text('Group Bluetooth Screen Content'),
      ),
    );
  }
}
