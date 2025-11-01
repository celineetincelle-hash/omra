import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/bloc/connectivity_bloc.dart';
import '../core/bloc/connectivity_event.dart';
import '../core/bloc/connectivity_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.map, 'label': tr('map'), 'route': '/map'},
      {'icon': Icons.directions_walk, 'label': tr('rituals'), 'route': '/rituals'},
      {'icon': Icons.menu_book, 'label': tr('duas'), 'route': '/duas'},
      {'icon': Icons.mic, 'label': tr('assistant'), 'route': '/assistant'},
      {'icon': Icons.group, 'label': tr('group_tracking'), 'route': '/group'},
      {'icon': Icons.bluetooth_searching, 'label': tr('bluetooth_members'), 'route': '/group_bluetooth'},
      {'icon': Icons.phone_in_talk, 'label': tr('useful_links'), 'route': '/links'},
      {'icon': Icons.share_location, 'label': tr('share_location'), 'route': '/share'},
      {'icon': Icons.favorite, 'label': tr('health_dashboard'), 'route': '/health'},
      {'icon': Icons.person, 'label': tr('profile'), 'route': '/profile'},
      {'icon': Icons.settings, 'label': tr('settings'), 'route': '/settings'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('home_title')),
        actions: [
          BlocBuilder<ConnectivityBloc, ConnectivityState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        state.isConnected ? Icons.wifi : Icons.wifi_off,
                        color: state.isConnected ? Colors.white : Colors.red,
                      ),
                onPressed: () {
                  context.read<ConnectivityBloc>().add(CheckConnectivity());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, connectivityState) {
          if (connectivityState.isChecking) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!connectivityState.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.signal_wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(tr('no_internet')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConnectivityBloc>().add(CheckConnectivity());
                    },
                    child: Text(tr('retry')),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ConnectivityBloc>().add(CheckConnectivity());
            },
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              children: items.map((e) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go(e['route'] as String),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(e['icon'] as IconData, size: 48, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(e['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
