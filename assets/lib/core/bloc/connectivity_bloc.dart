import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';
import '../services/connectivity_service.dart';

/// BLoC pour gérer la connectivité
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService connectivityService;

  ConnectivityBloc(this.connectivityService)
      : super(const ConnectivityState.initial()) {
    // Enregistrer les gestionnaires d'événements
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Démarrer l'écoute des changements de connectivité
    connectivityService.startListening(this);
  }

  /// Gestionnaire pour vérifier la connectivité
  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(state.copyWith(isChecking: true));

    try {
      final result = await connectivityService.checkConnectivity();
      final isConnected = result != ConnectivityResult.none;

      emit(state.copyWith(
        isConnected: isConnected,
        isChecking: false,
        connectivityResult: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        isConnected: false,
        isChecking: false,
      ));
    }
  }

  /// Gestionnaire pour les changements de connectivité
  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    final isConnected = event.result != ConnectivityResult.none;

    emit(state.copyWith(
      isConnected: isConnected,
      connectivityResult: event.result,
    ));
  }

  @override
  Future<void> close() {
    connectivityService.dispose();
    return super.close();
  }
}
