import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('assistant')),
      ),
      body: const Center(
        child: Text('Assistant Screen Content'),
      ),
    );
  }
}
