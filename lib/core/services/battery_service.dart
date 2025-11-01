
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_plus/battery_plus.dart' as battery_plus;
import 'package:equatable/equatable.dart';

// États
class BatteryState extends Equatable {
  final battery_plus.BatteryState batteryState;
  final int batteryLevel;
  final bool isOptimized;

  const BatteryState({
    required this.batteryState,
    required this.batteryLevel,
    required this.isOptimized,
  });

  @override
  List<Object> get props => [batteryState, batteryLevel, isOptimized];

  BatteryState copyWith({
    battery_plus.BatteryState? batteryState,
    int? batteryLevel,
    bool? isOptimized,
  }) {
    return BatteryState(
      batteryState: batteryState ?? this.batteryState,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isOptimized: isOptimized ?? this.isOptimized,
    );
  }
}

// Événements
abstract class BatteryEvent extends Equatable {
  const BatteryEvent();

  @override
  List<Object> get props => [];
}

class CheckBatteryStatus extends BatteryEvent {}

class BatteryStateChanged extends BatteryEvent {
  final battery_plus.BatteryState batteryState;
  final int batteryLevel;

  const BatteryStateChanged(this.batteryState, this.batteryLevel);

  @override
  List<Object> get props => [batteryState, batteryLevel];
}

class ToggleBatteryOptimization extends BatteryEvent {}

// Bloc
class BatteryBloc extends Bloc<BatteryEvent, BatteryState> {
  final battery_plus.Battery _battery = battery_plus.Battery();
  late StreamSubscription<battery_plus.BatteryState> _batteryStateSubscription;

  BatteryBloc() : super(const BatteryState(
    batteryState: battery_plus.BatteryState.unknown,
    batteryLevel: 0,
    isOptimized: false,
  )) {
    on<CheckBatteryStatus>(_onCheckBatteryStatus);
    on<BatteryStateChanged>(_onBatteryStateChanged);
    on<ToggleBatteryOptimization>(_onToggleBatteryOptimization);

    // Écouter les changements d'état de la batterie
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      _battery.batteryLevel.then((level) {
        add(BatteryStateChanged(state, level));
      });
    });

    // Vérifier l'état initial de la batterie
    add(CheckBatteryStatus());
  }

  Future<void> _onCheckBatteryStatus(
    CheckBatteryStatus event,
    Emitter<BatteryState> emit,
  ) async {
    try {
      final batteryState = await _battery.batteryState;
      final batteryLevel = await _battery.batteryLevel;

      emit(state.copyWith(
        batteryState: batteryState,
        batteryLevel: batteryLevel,
      ));
    } catch (e) {
      print('Error checking battery status: $e');
    }
  }

  void _onBatteryStateChanged(
    BatteryStateChanged event,
    Emitter<BatteryState> emit,
  ) {
    emit(state.copyWith(
      batteryState: event.batteryState,
      batteryLevel: event.batteryLevel,
    ));
  }

  void _onToggleBatteryOptimization(
    ToggleBatteryOptimization event,
    Emitter<BatteryState> emit,
  ) {
    emit(state.copyWith(isOptimized: !state.isOptimized));
  }

  @override
  Future<void> close() {
    _batteryStateSubscription.cancel();
    return super.close();
  }
}
