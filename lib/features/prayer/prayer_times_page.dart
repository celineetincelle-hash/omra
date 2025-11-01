import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:omra_track/providers/prayer_provider.dart';
import 'package:omra_track/services/localization_service.dart';
import 'package:omra_track/utils/app_theme.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('prayer_times'.tr(context)),
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, prayerProvider, child) {
          if (prayerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prayerProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    prayerProvider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => prayerProvider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final prayerTimes = prayerProvider.prayerTimes;
          final nextPrayer = prayerProvider.nextPrayer;

          return RefreshIndicator(
            onRefresh: () => prayerProvider.fetchPrayerTimes(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Next prayer card
                  if (nextPrayer != null && prayerProvider.nextPrayerTime != null)
                    Card(
                      color: AppTheme.primaryGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.mosque,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'next_prayer'.tr(context),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextPrayer.tr(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('HH:mm').format(prayerProvider.nextPrayerTime!),
                              style: const TextStyle(
                                color: AppTheme.secondaryGold,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  Text(
                    'prayer_times'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Prayer times list
                  if (prayerTimes != null) ...[
                    _buildPrayerTimeCard(
                      context,
                      'fajr'.tr(context),
                      prayerTimes.fajr,
                      nextPrayer == 'fajr',
                    ),
                    _buildPrayerTimeCard(
                      context,
                      'dhuhr'.tr(context),
                      prayerTimes.dhuhr,
                      nextPrayer == 'dhuhr',
                    ),
                    _buildPrayerTimeCard(
                      context,
                      'asr'.tr(context),
                      prayerTimes.asr,
                      nextPrayer == 'asr',
                    ),
                    _buildPrayerTimeCard(
                      context,
                      'maghrib'.tr(context),
                      prayerTimes.maghrib,
                      nextPrayer == 'maghrib',
                    ),
                    _buildPrayerTimeCard(
                      context,
                      'isha'.tr(context),
                      prayerTimes.isha,
                      nextPrayer == 'isha',
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  // Qibla direction button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to Qibla compass (can be implemented separately)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('qibla_direction'.tr(context)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore),
                      label: Text('qibla_direction'.tr(context)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    BuildContext context,
    String prayerName,
    DateTime time,
    bool isNext,
  ) {
    return Card(
      color: isNext ? const Color.fromRGBO(74, 124, 89, 0.1) : null,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNext
                ? const Color.fromRGBO(46, 93, 49, 0.2)
                : const Color.fromRGBO(158, 158, 158, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time,
            color: isNext ? AppTheme.primaryGreen : Colors.grey,
          ),
        ),
        title: Text(
          prayerName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isNext ? AppTheme.primaryGreen : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
