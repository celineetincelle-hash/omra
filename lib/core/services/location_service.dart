import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart'; // Utilisation de latlong2 pour LatLng

// États
class LocationState extends Equatable {
  final bool isServiceEnabled;
  final LocationPermission permissionStatus;
  final LatLng? lastKnownPosition;
  final bool isTracking;

  const LocationState({
    required this.isServiceEnabled,
    required this.permissionStatus,
    this.lastKnownPosition,
    this.isTracking = false,
  });

  @override
  List<Object?> get props => [isServiceEnabled, permissionStatus, lastKnownPosition, isTracking];

  LocationState copyWith({
    bool? isServiceEnabled,
    LocationPermission? permissionStatus,
    LatLng? lastKnownPosition,
    bool? isTracking,
  }) {
    return LocationState(
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      lastKnownPosition: lastKnownPosition ?? this.lastKnownPosition,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

// Événements
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class CheckLocationStatus extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;

  const LocationUpdated(this.position);

  @override
  List<Object> get props => [position];
}

class ToggleTracking extends LocationEvent {}

// Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationBloc() : super(const LocationState(
    isServiceEnabled: false,
    permissionStatus: LocationPermission.denied,
  )) {
    on<CheckLocationStatus>(_onCheckLocationStatus);
    on<LocationUpdated>(_onLocationUpdated);
    on<ToggleTracking>(_onToggleTracking);

    add(CheckLocationStatus());
  }

  Future<void> _onCheckLocationStatus(
    CheckLocationStatus event,
    Emitter<LocationState> emit,
  ) async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    var permissionStatus = await Geolocator.checkPermission();

    if (permissionStatus == LocationPermission.denied) {
      permissionStatus = await Geolocator.requestPermission();
    }

    emit(state.copyWith(
      isServiceEnabled: isServiceEnabled,
      permissionStatus: permissionStatus,
    ));
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(
      lastKnownPosition: LatLng(event.position.latitude, event.position.longitude),
    ));
  }

  void _onToggleTracking(
    ToggleTracking event,
    Emitter<LocationState> emit,
  ) {
    if (state.isTracking) {
      _positionStreamSubscription?.cancel();
      emit(state.copyWith(isTracking: false));
    } else if (state.isServiceEnabled && state.permissionStatus != LocationPermission.deniedForever) {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Mètres
        ),
      ).listen(
        (Position position) {
          add(LocationUpdated(position));
        },
        onError: (error) {
          print('Location stream error: \$error');
        },
      );
      emit(state.copyWith(isTracking: true));
    }
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
