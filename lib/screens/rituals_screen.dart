import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RitualsScreen extends StatelessWidget {
  const RitualsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('rituals')),
      ),
      body: const Center(
        child: Text('Rituals Screen Content'),
      ),
    );
  }
}
