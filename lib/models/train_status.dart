import 'package:freezed_annotation/freezed_annotation.dart';

part 'train_status.freezed.dart';
part 'train_status.g.dart';

@freezed
class TrainStatus with _$TrainStatus {
  const factory TrainStatus({
    @JsonKey(name: 'connected_trains') required int connectedTrains,
    required Map<String, Train> trains,
  }) = _TrainStatus;

  factory TrainStatus.fromJson(Map<String, dynamic> json) =>
      _$TrainStatusFromJson(json);
}

@freezed
class Train with _$Train {
  const factory Train({
    required String status,
    required double speed,
    required String direction,
    required String name,
    @JsonKey(name: 'last_update_seconds_ago') required double lastUpdateSecondsAgo,
    required int rssi,
  }) = _Train;

  factory Train.fromJson(Map<String, dynamic> json) => _$TrainFromJson(json);
}
