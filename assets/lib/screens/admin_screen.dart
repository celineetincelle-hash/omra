import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:omra_track/providers/auth_provider.dart';
import 'package:omra_track/providers/group_provider.dart';
import 'package:omra_track/providers/location_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData();
    });
  }

  Future<void> _loadGroupData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (authProvider.currentUser?.groupId.isNotEmpty == true) {
      await groupProvider.loadGroupData(authProvider.currentUser!.groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    if (authProvider.currentUser?.isAdmin != true) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Accès refusé"),
            ),
            body: const Center(
              child: Text("Vous n'avez pas les permissions nécessaires pour accéder à cette page."),
            ),
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panneau d'administration"),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              _onItemTapped(index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard_outlined),
                label: Text("Tableau de bord"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group),
                selectedIcon: Icon(Icons.group_outlined),
                label: Text("Groupes"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people_alt_outlined),
                label: Text("Membres"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                selectedIcon: Icon(Icons.warning_amber),
                label: Text("Alertes"),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: _buildPage(_selectedIndex, groupProvider, locationProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, GroupProvider groupProvider, LocationProvider locationProvider) {
    switch (index) {
      case 0:
        return _buildDashboard(groupProvider, locationProvider);
      case 1:
        return _buildGroupManagement(groupProvider);
      case 2:
        return _buildMemberManagement(groupProvider);
      case 3:
        return _buildAlertsPage(locationProvider);
      default:
        return const Text("Page non trouvée");
    }
  }

  Widget _buildDashboard(GroupProvider groupProvider, LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tableau de bord", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statistiques générales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Nombre de groupes: ${groupProvider.groups.length}"),
                  Text("Nombre total de membres: ${groupProvider.groups.fold<int>(0, (sum, group) => sum + group.memberIds.length)}"),
                  Text("Nombre d'appareils GPS connectés: ${locationProvider.gpsDevices.length}"),
                  Text("Nombre d'alertes actives: ${locationProvider.alerts.where((alert) => !alert.isResolved).length}"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Alertes récentes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: locationProvider.alerts.isEmpty
                ? const Center(child: Text("Aucune alerte récente."))
                : ListView.builder(
                    itemCount: locationProvider.alerts.length > 5 ? 5 : locationProvider.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = locationProvider.alerts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(alert.type == "SOS" ? Icons.sos : Icons.warning, color: alert.isResolved ? Colors.grey : Colors.red),
                          title: Text(alert.message),
                          subtitle: Text("${alert.timestamp.toLocal().toString().split(".")[0]} - ${alert.isResolved ? "Résolue" : "Active"}"),
                          trailing: alert.isResolved
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    // Logique pour résoudre l'alerte
                                    // locationProvider.resolveAlert(alert.id);
                                  },
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

  Widget _buildGroupManagement(GroupProvider groupProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gestion des groupes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Logique pour créer un nouveau groupe
            },
            icon: const Icon(Icons.add),
            label: const Text("Créer un nouveau groupe"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: groupProvider.groups.isEmpty
                ? const Center(child: Text("Aucun groupe créé pour le moment."))
                : ListView.builder(
                    itemCount: groupProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = groupProvider.groups[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(group.name),
                          subtitle: Text("Membres: ${group.memberIds.length}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Logique pour éditer le groupe
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Logique pour supprimer le groupe
                                },
                              ),
                            ],
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

  Widget _buildMemberManagement(GroupProvider groupProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gestion des membres", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Logique pour ajouter un nouveau membre
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Ajouter un nouveau membre"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: groupProvider.groupMembers.isEmpty
                ? const Center(child: Text("Aucun membre dans les groupes pour le moment."))
                : ListView.builder(
                    itemCount: groupProvider.groupMembers.length,
                    itemBuilder: (context, index) {
                      final member = groupProvider.groupMembers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(member.name),
                          subtitle: Text("Groupe: ${groupProvider.groups.firstWhere((g) => g.id == member.groupId).name}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Logique pour éditer le membre
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Logique pour supprimer le membre
                                },
                              ),
                            ],
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

  Widget _buildAlertsPage(LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Alertes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: locationProvider.alerts.isEmpty
                ? const Center(child: Text("Aucune alerte pour le moment."))
                : ListView.builder(
                    itemCount: locationProvider.alerts.length,
                    itemBuilder: (context, index) {
                      final alert = locationProvider.alerts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(alert.type == "SOS" ? Icons.sos : Icons.warning, color: alert.isResolved ? Colors.grey : Colors.red),
                          title: Text(alert.message),
                          subtitle: Text("Appareil: ${alert.deviceId} - ${alert.timestamp.toLocal().toString().split(".")[0]}"),
                          trailing: alert.isResolved
                              ? const Text("Résolue", style: TextStyle(color: Colors.grey)) 
                              : IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    // Logique pour résoudre l'alerte
                                    // locationProvider.resolveAlert(alert.id);
                                  },
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

  void _showQRCode(BuildContext context, String qrCode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Code du groupe',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: QrImageView(
                  data: qrCode,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                'Code: $qrCode',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, GroupProvider groupProvider) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un membre'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email du membre',
            hintText: 'Entrez l\'email de la personne à ajouter',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implémenter l\'ajout de membre par email
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité en cours de développement'),
                ),
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}


