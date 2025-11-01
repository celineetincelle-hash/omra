import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('health_dashboard')),
      ),
      body: const Center(
        child: Text('Health Dashboard Screen Content'),
      ),
    );
  }
}
