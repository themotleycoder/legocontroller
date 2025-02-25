// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'train_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainStatus _$TrainStatusFromJson(Map<String, dynamic> json) {
  return _TrainStatus.fromJson(json);
}

/// @nodoc
mixin _$TrainStatus {
  @JsonKey(name: 'connected_trains')
  int get connectedTrains => throw _privateConstructorUsedError;
  Map<String, Train> get trains => throw _privateConstructorUsedError;

  /// Serializes this TrainStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainStatusCopyWith<TrainStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainStatusCopyWith<$Res> {
  factory $TrainStatusCopyWith(
          TrainStatus value, $Res Function(TrainStatus) then) =
      _$TrainStatusCopyWithImpl<$Res, TrainStatus>;
  @useResult
  $Res call(
      {@JsonKey(name: 'connected_trains') int connectedTrains,
      Map<String, Train> trains});
}

/// @nodoc
class _$TrainStatusCopyWithImpl<$Res, $Val extends TrainStatus>
    implements $TrainStatusCopyWith<$Res> {
  _$TrainStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedTrains = null,
    Object? trains = null,
  }) {
    return _then(_value.copyWith(
      connectedTrains: null == connectedTrains
          ? _value.connectedTrains
          : connectedTrains // ignore: cast_nullable_to_non_nullable
              as int,
      trains: null == trains
          ? _value.trains
          : trains // ignore: cast_nullable_to_non_nullable
              as Map<String, Train>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainStatusImplCopyWith<$Res>
    implements $TrainStatusCopyWith<$Res> {
  factory _$$TrainStatusImplCopyWith(
          _$TrainStatusImpl value, $Res Function(_$TrainStatusImpl) then) =
      __$$TrainStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'connected_trains') int connectedTrains,
      Map<String, Train> trains});
}

/// @nodoc
class __$$TrainStatusImplCopyWithImpl<$Res>
    extends _$TrainStatusCopyWithImpl<$Res, _$TrainStatusImpl>
    implements _$$TrainStatusImplCopyWith<$Res> {
  __$$TrainStatusImplCopyWithImpl(
      _$TrainStatusImpl _value, $Res Function(_$TrainStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedTrains = null,
    Object? trains = null,
  }) {
    return _then(_$TrainStatusImpl(
      connectedTrains: null == connectedTrains
          ? _value.connectedTrains
          : connectedTrains // ignore: cast_nullable_to_non_nullable
              as int,
      trains: null == trains
          ? _value._trains
          : trains // ignore: cast_nullable_to_non_nullable
              as Map<String, Train>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainStatusImpl implements _TrainStatus {
  const _$TrainStatusImpl(
      {@JsonKey(name: 'connected_trains') required this.connectedTrains,
      required final Map<String, Train> trains})
      : _trains = trains;

  factory _$TrainStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainStatusImplFromJson(json);

  @override
  @JsonKey(name: 'connected_trains')
  final int connectedTrains;
  final Map<String, Train> _trains;
  @override
  Map<String, Train> get trains {
    if (_trains is EqualUnmodifiableMapView) return _trains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_trains);
  }

  @override
  String toString() {
    return 'TrainStatus(connectedTrains: $connectedTrains, trains: $trains)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainStatusImpl &&
            (identical(other.connectedTrains, connectedTrains) ||
                other.connectedTrains == connectedTrains) &&
            const DeepCollectionEquality().equals(other._trains, _trains));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, connectedTrains,
      const DeepCollectionEquality().hash(_trains));

  /// Create a copy of TrainStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainStatusImplCopyWith<_$TrainStatusImpl> get copyWith =>
      __$$TrainStatusImplCopyWithImpl<_$TrainStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainStatusImplToJson(
      this,
    );
  }
}

abstract class _TrainStatus implements TrainStatus {
  const factory _TrainStatus(
      {@JsonKey(name: 'connected_trains') required final int connectedTrains,
      required final Map<String, Train> trains}) = _$TrainStatusImpl;

  factory _TrainStatus.fromJson(Map<String, dynamic> json) =
      _$TrainStatusImpl.fromJson;

  @override
  @JsonKey(name: 'connected_trains')
  int get connectedTrains;
  @override
  Map<String, Train> get trains;

  /// Create a copy of TrainStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainStatusImplCopyWith<_$TrainStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Train _$TrainFromJson(Map<String, dynamic> json) {
  return _Train.fromJson(json);
}

/// @nodoc
mixin _$Train {
  String get status => throw _privateConstructorUsedError;
  double get speed => throw _privateConstructorUsedError;
  String get direction => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'selfDrive', defaultValue: false)
  bool get selfDrive => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_update_seconds_ago')
  double get lastUpdateSecondsAgo => throw _privateConstructorUsedError;
  int get rssi => throw _privateConstructorUsedError;

  /// Serializes this Train to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Train
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainCopyWith<Train> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainCopyWith<$Res> {
  factory $TrainCopyWith(Train value, $Res Function(Train) then) =
      _$TrainCopyWithImpl<$Res, Train>;
  @useResult
  $Res call(
      {String status,
      double speed,
      String direction,
      String name,
      @JsonKey(name: 'selfDrive', defaultValue: false) bool selfDrive,
      @JsonKey(name: 'last_update_seconds_ago') double lastUpdateSecondsAgo,
      int rssi});
}

/// @nodoc
class _$TrainCopyWithImpl<$Res, $Val extends Train>
    implements $TrainCopyWith<$Res> {
  _$TrainCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Train
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? speed = null,
    Object? direction = null,
    Object? name = null,
    Object? selfDrive = null,
    Object? lastUpdateSecondsAgo = null,
    Object? rssi = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      speed: null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      selfDrive: null == selfDrive
          ? _value.selfDrive
          : selfDrive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateSecondsAgo: null == lastUpdateSecondsAgo
          ? _value.lastUpdateSecondsAgo
          : lastUpdateSecondsAgo // ignore: cast_nullable_to_non_nullable
              as double,
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainImplCopyWith<$Res> implements $TrainCopyWith<$Res> {
  factory _$$TrainImplCopyWith(
          _$TrainImpl value, $Res Function(_$TrainImpl) then) =
      __$$TrainImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String status,
      double speed,
      String direction,
      String name,
      @JsonKey(name: 'selfDrive', defaultValue: false) bool selfDrive,
      @JsonKey(name: 'last_update_seconds_ago') double lastUpdateSecondsAgo,
      int rssi});
}

/// @nodoc
class __$$TrainImplCopyWithImpl<$Res>
    extends _$TrainCopyWithImpl<$Res, _$TrainImpl>
    implements _$$TrainImplCopyWith<$Res> {
  __$$TrainImplCopyWithImpl(
      _$TrainImpl _value, $Res Function(_$TrainImpl) _then)
      : super(_value, _then);

  /// Create a copy of Train
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? speed = null,
    Object? direction = null,
    Object? name = null,
    Object? selfDrive = null,
    Object? lastUpdateSecondsAgo = null,
    Object? rssi = null,
  }) {
    return _then(_$TrainImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      speed: null == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as double,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      selfDrive: null == selfDrive
          ? _value.selfDrive
          : selfDrive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateSecondsAgo: null == lastUpdateSecondsAgo
          ? _value.lastUpdateSecondsAgo
          : lastUpdateSecondsAgo // ignore: cast_nullable_to_non_nullable
              as double,
      rssi: null == rssi
          ? _value.rssi
          : rssi // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainImpl implements _Train {
  const _$TrainImpl(
      {required this.status,
      required this.speed,
      required this.direction,
      required this.name,
      @JsonKey(name: 'selfDrive', defaultValue: false) required this.selfDrive,
      @JsonKey(name: 'last_update_seconds_ago')
      required this.lastUpdateSecondsAgo,
      required this.rssi});

  factory _$TrainImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainImplFromJson(json);

  @override
  final String status;
  @override
  final double speed;
  @override
  final String direction;
  @override
  final String name;
  @override
  @JsonKey(name: 'selfDrive', defaultValue: false)
  final bool selfDrive;
  @override
  @JsonKey(name: 'last_update_seconds_ago')
  final double lastUpdateSecondsAgo;
  @override
  final int rssi;

  @override
  String toString() {
    return 'Train(status: $status, speed: $speed, direction: $direction, name: $name, selfDrive: $selfDrive, lastUpdateSecondsAgo: $lastUpdateSecondsAgo, rssi: $rssi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.selfDrive, selfDrive) ||
                other.selfDrive == selfDrive) &&
            (identical(other.lastUpdateSecondsAgo, lastUpdateSecondsAgo) ||
                other.lastUpdateSecondsAgo == lastUpdateSecondsAgo) &&
            (identical(other.rssi, rssi) || other.rssi == rssi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, speed, direction, name,
      selfDrive, lastUpdateSecondsAgo, rssi);

  /// Create a copy of Train
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainImplCopyWith<_$TrainImpl> get copyWith =>
      __$$TrainImplCopyWithImpl<_$TrainImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainImplToJson(
      this,
    );
  }
}

abstract class _Train implements Train {
  const factory _Train(
      {required final String status,
      required final double speed,
      required final String direction,
      required final String name,
      @JsonKey(name: 'selfDrive', defaultValue: false)
      required final bool selfDrive,
      @JsonKey(name: 'last_update_seconds_ago')
      required final double lastUpdateSecondsAgo,
      required final int rssi}) = _$TrainImpl;

  factory _Train.fromJson(Map<String, dynamic> json) = _$TrainImpl.fromJson;

  @override
  String get status;
  @override
  double get speed;
  @override
  String get direction;
  @override
  String get name;
  @override
  @JsonKey(name: 'selfDrive', defaultValue: false)
  bool get selfDrive;
  @override
  @JsonKey(name: 'last_update_seconds_ago')
  double get lastUpdateSecondsAgo;
  @override
  int get rssi;

  /// Create a copy of Train
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainImplCopyWith<_$TrainImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
