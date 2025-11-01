import 'package:flutter/material.dart';
import 'package:omra_track/models/circuit_model.dart';
import 'package:omra_track/utils/app_theme.dart';

class CircuitDetailsScreen extends StatelessWidget {
  final CircuitModel circuit;

  const CircuitDetailsScreen({super.key, required this.circuit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(circuit.title),
        backgroundColor: circuit.isPremium ? AppTheme.premiumColor : Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre et Sous-titre
            Text(
              circuit.title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: circuit.isPremium ? AppTheme.premiumColor : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              circuit.subtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 32.0),

            // Description
            Text(
              'Description du circuit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              circuit.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 32.0),

            // Détails clés
            _buildDetailRow(
              context,
              Icons.calendar_month,
              'Durée',
              circuit.duration,
            ),
            _buildDetailRow(
              context,
              Icons.location_city,
              'Destinations',
              circuit.destinations,
            ),
            _buildDetailRow(
              context,
              circuit.isPremium ? Icons.star : Icons.check_circle,
              'Type de circuit',
              circuit.isPremium ? 'Premium' : 'Classique',
              color: circuit.isPremium ? AppTheme.premiumColor : Colors.green,
            ),
            
            const SizedBox(height: 32.0),

            // Bouton d'action (Exemple)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Logique de réservation ou de demande d'information
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Demande d\'information pour ${circuit.title} envoyée !')),
                  );
                },
                icon: const Icon(Icons.book_online),
                label: const Text('Réserver ce circuit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
