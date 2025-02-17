import 'package:freezed_annotation/freezed_annotation.dart';
part 'switch_status.freezed.dart';
part 'switch_status.g.dart';

enum SwitchPosition {
  STRAIGHT,  // position = 0
  DIVERGING       // position = 1
}

@freezed
class SwitchStatus with _$SwitchStatus {
  const factory SwitchStatus({
    @JsonKey(name: 'connected_switches') required int connectedSwitches,
    required Map<String, Switch> switches,
  }) = _SwitchStatus;

  factory SwitchStatus.fromJson(Map<String, dynamic> json) =>
      _$SwitchStatusFromJson(json);
}

@freezed
class Switch with _$Switch {
  const factory Switch({
    @JsonKey(name: 'switch_positions') required Map<String, int> switchPositions,
    @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0) required double lastUpdateSecondsAgo,
    required String name,
    required int status,
    required bool connected,
    required bool active,
    @JsonKey(name: 'port_connections') Map<String, dynamic>? portConnections,
  }) = _Switch;

  factory Switch.fromJson(Map<String, dynamic> json) => _$SwitchFromJson(json);
}
