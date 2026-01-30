import 'package:json_annotation/json_annotation.dart';

part 'train_status.g.dart';

@JsonSerializable(explicitToJson: true)
class TrainStatus {
  @JsonKey(name: 'connected_trains')
  final int connectedTrains;

  final Map<String, Train> trains;

  const TrainStatus({required this.connectedTrains, required this.trains});

  factory TrainStatus.fromJson(Map<String, dynamic> json) =>
      _$TrainStatusFromJson(json);

  Map<String, dynamic> toJson() => _$TrainStatusToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainStatus &&
          runtimeType == other.runtimeType &&
          connectedTrains == other.connectedTrains &&
          _mapsEqual(trains, other.trains);

  @override
  int get hashCode => connectedTrains.hashCode ^ trains.hashCode;

  @override
  String toString() =>
      'TrainStatus(connectedTrains: $connectedTrains, trains: $trains)';

  TrainStatus copyWith({int? connectedTrains, Map<String, Train>? trains}) {
    return TrainStatus(
      connectedTrains: connectedTrains ?? this.connectedTrains,
      trains: trains ?? this.trains,
    );
  }

  static bool _mapsEqual(Map<String, Train> a, Map<String, Train> b) {
    if (a.length != b.length) return false;
    for (var key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

@JsonSerializable()
class Train {
  final String status;
  final double speed;
  final String direction;
  final String name;

  @JsonKey(name: 'self_drive', defaultValue: false)
  final bool selfDrive;

  @JsonKey(name: 'last_update_seconds_ago')
  final double lastUpdateSecondsAgo;

  final int rssi;

  const Train({
    required this.status,
    required this.speed,
    required this.direction,
    required this.name,
    required this.selfDrive,
    required this.lastUpdateSecondsAgo,
    required this.rssi,
  });

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json);

  Map<String, dynamic> toJson() => _$TrainToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Train &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          speed == other.speed &&
          direction == other.direction &&
          name == other.name &&
          selfDrive == other.selfDrive &&
          lastUpdateSecondsAgo == other.lastUpdateSecondsAgo &&
          rssi == other.rssi;

  @override
  int get hashCode =>
      status.hashCode ^
      speed.hashCode ^
      direction.hashCode ^
      name.hashCode ^
      selfDrive.hashCode ^
      lastUpdateSecondsAgo.hashCode ^
      rssi.hashCode;

  @override
  String toString() =>
      'Train(status: $status, speed: $speed, direction: $direction, '
      'name: $name, selfDrive: $selfDrive, '
      'lastUpdateSecondsAgo: $lastUpdateSecondsAgo, rssi: $rssi)';

  Train copyWith({
    String? status,
    double? speed,
    String? direction,
    String? name,
    bool? selfDrive,
    double? lastUpdateSecondsAgo,
    int? rssi,
  }) {
    return Train(
      status: status ?? this.status,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
      name: name ?? this.name,
      selfDrive: selfDrive ?? this.selfDrive,
      lastUpdateSecondsAgo: lastUpdateSecondsAgo ?? this.lastUpdateSecondsAgo,
      rssi: rssi ?? this.rssi,
    );
  }
}
