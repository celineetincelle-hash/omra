import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ShareLocationScreen extends StatelessWidget {
  const ShareLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('share_location')),
      ),
      body: const Center(
        child: Text('Share Location Screen Content'),
      ),
    );
  }
}
