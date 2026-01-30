// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwitchStatus _$SwitchStatusFromJson(Map<String, dynamic> json) => SwitchStatus(
  connectedSwitches: (json['connected_switches'] as num).toInt(),
  switches: (json['switches'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Switch.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$SwitchStatusToJson(SwitchStatus instance) =>
    <String, dynamic>{
      'connected_switches': instance.connectedSwitches,
      'switches': instance.switches.map((k, e) => MapEntry(k, e.toJson())),
    };

Switch _$SwitchFromJson(Map<String, dynamic> json) => Switch(
  switchPositions: Map<String, int>.from(json['switch_positions'] as Map),
  switchStates: Map<String, int>.from(json['switch_states'] as Map),
  lastUpdateSecondsAgo:
      (json['last_update_seconds_ago'] as num?)?.toDouble() ?? 0.0,
  name: json['name'] as String,
  status: (json['status'] as num).toInt(),
  connected: json['connected'] as bool? ?? false,
  active: json['active'] as bool? ?? false,
  portConnections: json['port_connections'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SwitchToJson(Switch instance) => <String, dynamic>{
  'switch_positions': instance.switchPositions,
  'switch_states': instance.switchStates,
  'last_update_seconds_ago': instance.lastUpdateSecondsAgo,
  'name': instance.name,
  'status': instance.status,
  'connected': instance.connected,
  'active': instance.active,
  'port_connections': instance.portConnections,
};
