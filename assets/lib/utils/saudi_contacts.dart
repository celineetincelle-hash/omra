class EmergencyContact {
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final String number;
  final String icon;

  EmergencyContact({
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.number,
    required this.icon,
  });
}

class SaudiEmergencyContacts {
  static final List<EmergencyContact> contacts = [
    EmergencyContact(
      nameAr: 'الإسعاف',
      nameEn: 'Ambulance',
      nameFr: 'Ambulance',
      number: '997',
      icon: 'ambulance',
    ),
    EmergencyContact(
      nameAr: 'الشرطة',
      nameEn: 'Police',
      nameFr: 'Police',
      number: '999',
      icon: 'police',
    ),
    EmergencyContact(
      nameAr: 'الدفاع المدني',
      nameEn: 'Civil Defense',
      nameFr: 'Défense Civile',
      number: '998',
      icon: 'fire',
    ),
    EmergencyContact(
      nameAr: 'وزارة الحج والعمرة',
      nameEn: 'Ministry of Hajj',
      nameFr: 'Ministère du Hajj',
      number: '8004304444',
      icon: 'ministry',
    ),
    EmergencyContact(
      nameAr: 'مركز بلاغات الطوارئ الموحد',
      nameEn: 'Unified Emergency Center',
      nameFr: 'Centre d\'Urgence Unifié',
      number: '911',
      icon: 'emergency',
    ),
    EmergencyContact(
      nameAr: 'الهلال الأحمر',
      nameEn: 'Red Crescent',
      nameFr: 'Croissant Rouge',
      number: '997',
      icon: 'medical',
    ),
  ];

  static String getName(EmergencyContact contact, String language) {
    switch (language) {
      case 'ar':
        return contact.nameAr;
      case 'fr':
        return contact.nameFr;
      case 'en':
      default:
        return contact.nameEn;
    }
  }
}
