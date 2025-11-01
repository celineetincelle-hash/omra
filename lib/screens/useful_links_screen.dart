import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UsefulLinksScreen extends StatelessWidget {
  const UsefulLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('useful_links')),
      ),
      body: const Center(
        child: Text('Useful Links Screen Content'),
      ),
    );
  }
}
