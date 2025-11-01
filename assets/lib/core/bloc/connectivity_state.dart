import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// États de connectivité
class ConnectivityState extends Equatable {
  final bool isConnected;
  final bool isChecking;
  final ConnectivityResult? connectivityResult;

  const ConnectivityState({
    this.isConnected = false,
    this.isChecking = false,
    this.connectivityResult,
  });

  /// État initial
  const ConnectivityState.initial()
      : isConnected = false,
        isChecking = false,
        connectivityResult = null;

  /// État en cours de vérification
  ConnectivityState copyWith({
    bool? isConnected,
    bool? isChecking,
    ConnectivityResult? connectivityResult,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      isChecking: isChecking ?? this.isChecking,
      connectivityResult: connectivityResult ?? this.connectivityResult,
    );
  }

  @override
  List<Object?> get props => [isConnected, isChecking, connectivityResult];
}
