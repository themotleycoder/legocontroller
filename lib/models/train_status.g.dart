// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainStatusImpl _$$TrainStatusImplFromJson(Map<String, dynamic> json) =>
    _$TrainStatusImpl(
      connectedTrains: (json['connected_trains'] as num).toInt(),
      trains: (json['trains'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Train.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$TrainStatusImplToJson(_$TrainStatusImpl instance) =>
    <String, dynamic>{
      'connected_trains': instance.connectedTrains,
      'trains': instance.trains,
    };

_$TrainImpl _$$TrainImplFromJson(Map<String, dynamic> json) => _$TrainImpl(
      status: json['status'] as String,
      speed: (json['speed'] as num).toDouble(),
      direction: json['direction'] as String,
      name: json['name'] as String,
      selfDrive: json['selfDrive'] as bool? ?? false,
      lastUpdateSecondsAgo: (json['last_update_seconds_ago'] as num).toDouble(),
      rssi: (json['rssi'] as num).toInt(),
    );

Map<String, dynamic> _$$TrainImplToJson(_$TrainImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'speed': instance.speed,
      'direction': instance.direction,
      'name': instance.name,
      'selfDrive': instance.selfDrive,
      'last_update_seconds_ago': instance.lastUpdateSecondsAgo,
      'rssi': instance.rssi,
    };
