import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:omra_truck/core/bloc/connectivity_bloc.dart';
import 'package:omra_truck/core/bloc/connectivity_event.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  // Le type du StreamSubscription doit correspondre au Stream
  // connectivity_plus v5.0.2 retourne ConnectivityResult (pas List)
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Méthode pour obtenir l'état actuel de la connexion
  // Retourne Future<ConnectivityResult>
  Future<ConnectivityResult> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  // Méthode pour écouter les changements de connexion et les émettre via un BLoC
  void startListening(ConnectivityBloc bloc) {
    // Le type de l'écoute est maintenant Stream<ConnectivityResult>
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      // result est de type ConnectivityResult
      bloc.add(ConnectivityChanged(result));
    });
  }

  // Méthode pour vérifier si l'appareil est connecté
  static bool isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  // Méthode pour annuler l'abonnement
  void dispose() {
    _connectivitySubscription.cancel();
  }
}
