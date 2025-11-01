import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('duas')),
      ),
      body: const Center(
        child: Text('Duas Screen Content'),
      ),
    );
  }
}
