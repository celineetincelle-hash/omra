import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omra_track/providers/health_provider.dart';
import 'package:omra_track/services/localization_service.dart';
import 'package:omra_track/utils/app_theme.dart';

class HealthDashboardPage extends StatefulWidget {
  const HealthDashboardPage({super.key});

  @override
  State<HealthDashboardPage> createState() => _HealthDashboardPageState();
}

class _HealthDashboardPageState extends State<HealthDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('health_dashboard'.tr(context)),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    healthProvider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => healthProvider.initialize(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final healthData = healthProvider.currentHealthData;

          return RefreshIndicator(
            onRefresh: () => healthProvider.fetchHealthData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert banner if abnormal values
                  if (healthProvider.hasAbnormalValues())
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'health_warning'.tr(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Health metrics cards
                  _buildHealthMetricCard(
                    context,
                    icon: Icons.favorite,
                    title: 'heart_rate'.tr(context),
                    value: healthData?.heartRate?.toStringAsFixed(0) ?? '--',
                    unit: 'bpm'.tr(context),
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthMetricCard(
                    context,
                    icon: Icons.air,
                    title: 'oxygen_level'.tr(context),
                    value: healthData?.oxygenLevel?.toStringAsFixed(0) ?? '--',
                    unit: '%',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthMetricCard(
                    context,
                    icon: Icons.directions_walk,
                    title: 'daily_steps'.tr(context),
                    value: healthData?.steps?.toString() ?? '--',
                    unit: 'steps'.tr(context),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildHealthMetricCard(
                    context,
                    icon: Icons.monitor_heart,
                    title: 'blood_pressure'.tr(context),
                    value: healthData?.systolicBP != null && healthData?.diastolicBP != null
                        ? '${healthData!.systolicBP!.toStringAsFixed(0)}/${healthData.diastolicBP!.toStringAsFixed(0)}'
                        : '--',
                    unit: 'mmHg',
                    color: Colors.purple,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Heart Rate History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  
                  // Chart
                  if (healthProvider.healthHistory.isNotEmpty)
                    _buildHeartRateChart(healthProvider.healthHistory),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  color.red,
                  color.green,
                  color.blue,
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateChart(List<dynamic> history) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: history
                  .asMap()
                  .entries
                  .where((e) => e.value.heartRate != null)
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.heartRate!,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
