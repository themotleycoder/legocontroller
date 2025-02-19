// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwitchStatusImpl _$$SwitchStatusImplFromJson(Map<String, dynamic> json) =>
    _$SwitchStatusImpl(
      connectedSwitches: (json['connected_switches'] as num).toInt(),
      switches: (json['switches'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Switch.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$SwitchStatusImplToJson(_$SwitchStatusImpl instance) =>
    <String, dynamic>{
      'connected_switches': instance.connectedSwitches,
      'switches': instance.switches,
    };

_$SwitchImpl _$$SwitchImplFromJson(Map<String, dynamic> json) => _$SwitchImpl(
      switchPositions: Map<String, int>.from(json['switch_positions'] as Map),
      switchStates: Map<String, int>.from(json['switch_states'] as Map),
      lastUpdateSecondsAgo:
          (json['last_update_seconds_ago'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] as String,
      status: (json['status'] as num).toInt(),
      connected: json['connected'] as bool,
      active: json['active'] as bool? ?? true,
      portConnections: json['port_connections'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SwitchImplToJson(_$SwitchImpl instance) =>
    <String, dynamic>{
      'switch_positions': instance.switchPositions,
      'switch_states': instance.switchStates,
      'last_update_seconds_ago': instance.lastUpdateSecondsAgo,
      'name': instance.name,
      'status': instance.status,
      'connected': instance.connected,
      'active': instance.active,
      'port_connections': instance.portConnections,
    };
