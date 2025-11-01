import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Événements de connectivité
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour vérifier la connectivité
class CheckConnectivity extends ConnectivityEvent {
  const CheckConnectivity();
}

/// Événement déclenché lorsque la connectivité change
class ConnectivityChanged extends ConnectivityEvent {
  final ConnectivityResult result;

  const ConnectivityChanged(this.result);

  @override
  List<Object?> get props => [result];
}
