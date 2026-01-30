import 'package:json_annotation/json_annotation.dart';

part 'switch_status.g.dart';

// Switch position enum
enum SwitchPosition { STRAIGHT, DIVERGING }

@JsonSerializable(explicitToJson: true)
class SwitchStatus {
  @JsonKey(name: 'connected_switches')
  final int connectedSwitches;

  final Map<String, Switch> switches;

  const SwitchStatus({required this.connectedSwitches, required this.switches});

  factory SwitchStatus.fromJson(Map<String, dynamic> json) =>
      _$SwitchStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SwitchStatusToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchStatus &&
          runtimeType == other.runtimeType &&
          connectedSwitches == other.connectedSwitches &&
          _mapsEqual(switches, other.switches);

  @override
  int get hashCode => connectedSwitches.hashCode ^ switches.hashCode;

  @override
  String toString() =>
      'SwitchStatus(connectedSwitches: $connectedSwitches, switches: $switches)';

  SwitchStatus copyWith({
    int? connectedSwitches,
    Map<String, Switch>? switches,
  }) {
    return SwitchStatus(
      connectedSwitches: connectedSwitches ?? this.connectedSwitches,
      switches: switches ?? this.switches,
    );
  }

  static bool _mapsEqual(Map<String, Switch> a, Map<String, Switch> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

@JsonSerializable(explicitToJson: true)
class Switch {
  @JsonKey(name: 'switch_positions')
  final Map<String, int> switchPositions;

  @JsonKey(name: 'switch_states')
  final Map<String, int> switchStates;

  @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
  final double lastUpdateSecondsAgo;

  final String name;
  final int status;
  @JsonKey(defaultValue: false)
  final bool connected;
  @JsonKey(defaultValue: false)
  final bool active;

  @JsonKey(name: 'port_connections')
  final Map<String, dynamic>? portConnections;

  const Switch({
    required this.switchPositions,
    required this.switchStates,
    required this.lastUpdateSecondsAgo,
    required this.name,
    required this.status,
    this.connected = false,
    this.active = false,
    this.portConnections,
  });

  factory Switch.fromJson(Map<String, dynamic> json) => _$SwitchFromJson(json);

  Map<String, dynamic> toJson() => _$SwitchToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Switch &&
          runtimeType == other.runtimeType &&
          _intMapsEqual(switchPositions, other.switchPositions) &&
          _intMapsEqual(switchStates, other.switchStates) &&
          lastUpdateSecondsAgo == other.lastUpdateSecondsAgo &&
          name == other.name &&
          status == other.status &&
          connected == other.connected &&
          active == other.active &&
          _dynamicMapsEqual(portConnections, other.portConnections);

  @override
  int get hashCode =>
      switchPositions.hashCode ^
      switchStates.hashCode ^
      lastUpdateSecondsAgo.hashCode ^
      name.hashCode ^
      status.hashCode ^
      connected.hashCode ^
      active.hashCode ^
      portConnections.hashCode;

  @override
  String toString() =>
      'Switch(switchPositions: $switchPositions, switchStates: $switchStates, '
      'lastUpdateSecondsAgo: $lastUpdateSecondsAgo, name: $name, '
      'status: $status, connected: $connected, active: $active, '
      'portConnections: $portConnections)';

  Switch copyWith({
    Map<String, int>? switchPositions,
    Map<String, int>? switchStates,
    double? lastUpdateSecondsAgo,
    String? name,
    int? status,
    bool? connected,
    bool? active,
    Map<String, dynamic>? portConnections,
  }) {
    return Switch(
      switchPositions: switchPositions ?? this.switchPositions,
      switchStates: switchStates ?? this.switchStates,
      lastUpdateSecondsAgo: lastUpdateSecondsAgo ?? this.lastUpdateSecondsAgo,
      name: name ?? this.name,
      status: status ?? this.status,
      connected: connected ?? this.connected,
      active: active ?? this.active,
      portConnections: portConnections ?? this.portConnections,
    );
  }

  static bool _intMapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  static bool _dynamicMapsEqual(
    Map<String, dynamic>? a,
    Map<String, dynamic>? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
