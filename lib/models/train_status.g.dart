// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'train_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainStatus _$TrainStatusFromJson(Map<String, dynamic> json) => TrainStatus(
  connectedTrains: (json['connected_trains'] as num).toInt(),
  trains: (json['trains'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Train.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$TrainStatusToJson(TrainStatus instance) =>
    <String, dynamic>{
      'connected_trains': instance.connectedTrains,
      'trains': instance.trains.map((k, e) => MapEntry(k, e.toJson())),
    };

Train _$TrainFromJson(Map<String, dynamic> json) => Train(
  status: json['status'] as String,
  speed: (json['speed'] as num).toDouble(),
  direction: json['direction'] as String,
  name: json['name'] as String,
  selfDrive: json['self_drive'] as bool? ?? false,
  lastUpdateSecondsAgo: (json['last_update_seconds_ago'] as num).toDouble(),
  rssi: (json['rssi'] as num).toInt(),
);

Map<String, dynamic> _$TrainToJson(Train instance) => <String, dynamic>{
  'status': instance.status,
  'speed': instance.speed,
  'direction': instance.direction,
  'name': instance.name,
  'self_drive': instance.selfDrive,
  'last_update_seconds_ago': instance.lastUpdateSecondsAgo,
  'rssi': instance.rssi,
};
