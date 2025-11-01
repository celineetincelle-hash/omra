import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:omra_track/providers/auth_provider.dart';
import 'package:omra_track/providers/language_provider.dart';
import 'package:omra_track/services/localization_service.dart';
import 'package:omra_track/features/health/health_dashboard_page.dart';
import 'package:omra_track/features/medication/medication_list_page.dart';
import 'package:omra_track/features/prayer/prayer_times_page.dart';
import 'package:omra_track/features/emergency/emergency_contacts_page.dart';
import 'package:omra_track/utils/app_theme.dart';

class HomeScreenNew extends StatelessWidget {
  const HomeScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr(context)),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String languageCode) {
              context.read<LanguageProvider>().setLocale(Locale(languageCode));
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'ar',
                child: Row(
                  children: [
                    Text('🇸🇦'),
                    SizedBox(width: 8),
                    Text('العربية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    Text('🇫🇷'),
                    SizedBox(width: 8),
                    Text('Français'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Text('🇬🇧'),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
            ],
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.currentUser?.isAdmin == true) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'app_name'.tr(context),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Main feature buttons - Large and senior-friendly
            _buildLargeFeatureButton(
              context,
              icon: Icons.mosque,
              title: 'direction_to_mosque'.tr(context),
              color: AppTheme.primaryGreen,
              onTap: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildLargeFeatureButton(
              context,
              icon: Icons.medication,
              title: 'medication_reminders'.tr(context),
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationListPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildLargeFeatureButton(
              context,
              icon: Icons.favorite,
              title: 'health_advice'.tr(context),
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthDashboardPage(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildLargeFeatureButton(
              context,
              icon: Icons.phone,
              title: 'emergency_numbers'.tr(context),
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Secondary features in a grid
            Row(
              children: [
                Expanded(
                  child: _buildSmallFeatureButton(
                    context,
                    icon: Icons.access_time,
                    title: 'prayer'.tr(context),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerTimesPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallFeatureButton(
                    context,
                    icon: Icons.people,
                    title: 'contacts'.tr(context),
                    onTap: () {
                      Navigator.pushNamed(context, '/contacts');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Voice assistant - to be implemented
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('voice_assistant'.tr(context))),
          );
        },
        icon: const Icon(Icons.mic),
        label: Text('voice_assistant'.tr(context)),
        backgroundColor: AppTheme.secondaryGold,
      ),
    );
  }

  Widget _buildLargeFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
