import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:omra_track/utils/saudi_contacts.dart';
import 'package:omra_track/providers/language_provider.dart';
import 'package:omra_track/providers/location_provider.dart';
import 'package:omra_track/services/localization_service.dart';
import 'package:omra_track/utils/app_theme.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLanguage = languageProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('emergency_contacts'.tr(context)),
      ),
      body: Column(
        children: [
          // SOS Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'sos'.tr(context).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to call emergency or share location',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makeCall(context, '911'),
                        icon: const Icon(Icons.phone),
                        label: Text('call'.tr(context)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareLocation(context),
                        icon: const Icon(Icons.location_on),
                        label: Text('share_location'.tr(context)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Emergency contacts list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: SaudiEmergencyContacts.contacts.length,
              itemBuilder: (context, index) {
                final contact = SaudiEmergencyContacts.contacts[index];
                final name = SaudiEmergencyContacts.getName(contact, currentLanguage);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(46, 93, 49, 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(contact.icon),
                        color: AppTheme.primaryGreen,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      contact.number,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                      iconSize: 32,
                      onPressed: () => _makeCall(context, contact.number),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'ambulance':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.fire_extinguisher;
      case 'ministry':
        return Icons.account_balance;
      case 'emergency':
        return Icons.emergency;
      case 'medical':
        return Icons.medical_services;
      default:
        return Icons.phone;
    }
  }

  Future<void> _makeCall(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('emergency_call_initiated'.tr(context))),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make phone call')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _shareLocation(BuildContext context) async {
    try {
      final locationProvider = context.read<LocationProvider>();
      final position = locationProvider.currentPosition;

      if (position != null) {
        final lat = position.latitude;
        final lng = position.longitude;
        final mapsUrl = 'https://www.google.com/maps?q=$lat,$lng';
        
        if (!context.mounted) return;
        // In a real app, you would share this via SMS or messaging app
        // For now, we'll just show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'location_shared'.tr(context)}\n$mapsUrl'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final uri = Uri.parse(mapsUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not available')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing location: $e')),
      );
    }
  }
}
