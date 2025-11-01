import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GroupTrackingScreen extends StatelessWidget {
  const GroupTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('group_tracking')),
      ),
      body: const Center(
        child: Text('Group Tracking Screen Content'),
      ),
    );
  }
}
