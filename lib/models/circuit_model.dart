class CircuitModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String duration;
  final String destinations;
  final bool isPremium;

  CircuitModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.destinations,
    required this.isPremium,
  });

  // Données de circuit factices pour l'exemple
  static List<CircuitModel> mockCircuits = [
    CircuitModel(
      id: 'omra_premium',
      title: 'Circuit Omra Premium',
      subtitle: '15 jours - Médine et La Mecque',
      description: 'Un voyage spirituel de luxe de 15 jours incluant un hébergement 5 étoiles à Médine et à La Mecque, des repas gastronomiques et un accompagnement personnalisé par un guide expérimenté.',
      duration: '15 jours',
      destinations: 'Médine, La Mecque',
      isPremium: true,
    ),
    CircuitModel(
      id: 'omra_classique',
      title: 'Circuit Omra Classique',
      subtitle: '10 jours - La Mecque',
      description: 'Un circuit de 10 jours axé sur les rituels de l\'Omra à La Mecque, avec un hébergement confortable et un transport organisé. Idéal pour une première Omra.',
      duration: '10 jours',
      destinations: 'La Mecque',
      isPremium: false,
    ),
  ];
}
