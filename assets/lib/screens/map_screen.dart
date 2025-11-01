import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('map')),
      ),
      body: const Center(
        child: Text('Map Screen Content'),
      ),
    );
  }
}
