import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:omra_track/models/contact_model.dart';
import 'package:omra_track/widgets/custom_card.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  // Liste des contacts par défaut (peut être modifiée via l'admin)
  static const String _defaultGuideNumber = '+966 50 XXX XXXX'; // Remplacer par le vrai numéro
  
  static final List<ContactModel> _contacts = [
    ContactModel(
      id: '1',
      name: 'Guide principal',
      phoneNumber: _defaultGuideNumber,
      description: 'Votre guide pour le pèlerinage',
      type: ContactType.guide,
    ),
    ContactModel(
      id: '2',
      name: 'Agence Omra Track',
      phoneNumber: '+33 1 23 45 67 89',
      description: 'Service client de l\'agence',
      type: ContactType.agency,
    ),
    ContactModel(
      id: '3',
      name: 'Ambassade de France',
      phoneNumber: '+966 11 434 4000',
      description: 'Ambassade de France en Arabie Saoudite',
      type: ContactType.embassy,
    ),
    ContactModel(
      id: '4',
      name: 'Urgences Médicales',
      phoneNumber: '997',
      description: 'Numéro d\'urgence médical en Arabie Saoudite',
      type: ContactType.emergency,
    ),
    ContactModel(
      id: '5',
      name: 'Police',
      phoneNumber: '999',
      description: 'Numéro d\'urgence police en Arabie Saoudite',
      type: ContactType.emergency,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numéros utiles'),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return CustomCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getContactTypeColor(contact.type),
                child: Icon(
                  _getContactTypeIcon(contact.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.phoneNumber),
                  const SizedBox(height: 4),
                  Text(
                    contact.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _makePhoneCall(contact.phoneNumber),
                    icon: const Icon(Icons.phone),
                    color: Colors.green,
                    tooltip: 'Appeler',
                  ),
                  IconButton(
                    onPressed: () => _sendSMS(contact.phoneNumber),
                    icon: const Icon(Icons.message),
                    color: Colors.blue,
                    tooltip: 'Envoyer SMS',
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmergencyDialog(context),
        icon: const Icon(Icons.emergency),
        label: const Text('Urgence'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  Color _getContactTypeColor(ContactType type) {
    switch (type) {
      case ContactType.guide:
        return Colors.blue;
      case ContactType.agency:
        return Colors.green;
      case ContactType.embassy:
        return Colors.purple;
      case ContactType.emergency:
        return Colors.red;
      case ContactType.other:
        return Colors.grey;
    }
  }

  IconData _getContactTypeIcon(ContactType type) {
    switch (type) {
      case ContactType.guide:
        return Icons.person;
      case ContactType.agency:
        return Icons.business;
      case ContactType.embassy:
        return Icons.account_balance;
      case ContactType.emergency:
        return Icons.emergency;
      case ContactType.other:
        return Icons.contact_phone;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Gérer l'erreur
      debugPrint('Impossible d\'appeler $phoneNumber');
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // Gérer l'erreur
      debugPrint('Impossible d\'envoyer un SMS à $phoneNumber');
    }
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Urgence'),
          ],
        ),
        content: const Text(
          'En cas d\'urgence, contactez immédiatement les services d\'urgence locaux ou votre guide.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall('997'); // Urgences médicales
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Appeler 997'),
          ),
        ],
      ),
    );
  }
}

