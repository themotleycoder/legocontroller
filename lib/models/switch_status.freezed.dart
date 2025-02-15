// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'switch_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SwitchStatus _$SwitchStatusFromJson(Map<String, dynamic> json) {
  return _SwitchStatus.fromJson(json);
}

/// @nodoc
mixin _$SwitchStatus {
  @JsonKey(name: 'connected_switches')
  int get connectedSwitches => throw _privateConstructorUsedError;
  Map<String, Switch> get switches => throw _privateConstructorUsedError;

  /// Serializes this SwitchStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SwitchStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwitchStatusCopyWith<SwitchStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwitchStatusCopyWith<$Res> {
  factory $SwitchStatusCopyWith(
          SwitchStatus value, $Res Function(SwitchStatus) then) =
      _$SwitchStatusCopyWithImpl<$Res, SwitchStatus>;
  @useResult
  $Res call(
      {@JsonKey(name: 'connected_switches') int connectedSwitches,
      Map<String, Switch> switches});
}

/// @nodoc
class _$SwitchStatusCopyWithImpl<$Res, $Val extends SwitchStatus>
    implements $SwitchStatusCopyWith<$Res> {
  _$SwitchStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwitchStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedSwitches = null,
    Object? switches = null,
  }) {
    return _then(_value.copyWith(
      connectedSwitches: null == connectedSwitches
          ? _value.connectedSwitches
          : connectedSwitches // ignore: cast_nullable_to_non_nullable
              as int,
      switches: null == switches
          ? _value.switches
          : switches // ignore: cast_nullable_to_non_nullable
              as Map<String, Switch>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwitchStatusImplCopyWith<$Res>
    implements $SwitchStatusCopyWith<$Res> {
  factory _$$SwitchStatusImplCopyWith(
          _$SwitchStatusImpl value, $Res Function(_$SwitchStatusImpl) then) =
      __$$SwitchStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'connected_switches') int connectedSwitches,
      Map<String, Switch> switches});
}

/// @nodoc
class __$$SwitchStatusImplCopyWithImpl<$Res>
    extends _$SwitchStatusCopyWithImpl<$Res, _$SwitchStatusImpl>
    implements _$$SwitchStatusImplCopyWith<$Res> {
  __$$SwitchStatusImplCopyWithImpl(
      _$SwitchStatusImpl _value, $Res Function(_$SwitchStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwitchStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connectedSwitches = null,
    Object? switches = null,
  }) {
    return _then(_$SwitchStatusImpl(
      connectedSwitches: null == connectedSwitches
          ? _value.connectedSwitches
          : connectedSwitches // ignore: cast_nullable_to_non_nullable
              as int,
      switches: null == switches
          ? _value._switches
          : switches // ignore: cast_nullable_to_non_nullable
              as Map<String, Switch>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwitchStatusImpl implements _SwitchStatus {
  const _$SwitchStatusImpl(
      {@JsonKey(name: 'connected_switches') required this.connectedSwitches,
      required final Map<String, Switch> switches})
      : _switches = switches;

  factory _$SwitchStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwitchStatusImplFromJson(json);

  @override
  @JsonKey(name: 'connected_switches')
  final int connectedSwitches;
  final Map<String, Switch> _switches;
  @override
  Map<String, Switch> get switches {
    if (_switches is EqualUnmodifiableMapView) return _switches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_switches);
  }

  @override
  String toString() {
    return 'SwitchStatus(connectedSwitches: $connectedSwitches, switches: $switches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwitchStatusImpl &&
            (identical(other.connectedSwitches, connectedSwitches) ||
                other.connectedSwitches == connectedSwitches) &&
            const DeepCollectionEquality().equals(other._switches, _switches));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, connectedSwitches,
      const DeepCollectionEquality().hash(_switches));

  /// Create a copy of SwitchStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwitchStatusImplCopyWith<_$SwitchStatusImpl> get copyWith =>
      __$$SwitchStatusImplCopyWithImpl<_$SwitchStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwitchStatusImplToJson(
      this,
    );
  }
}

abstract class _SwitchStatus implements SwitchStatus {
  const factory _SwitchStatus(
      {@JsonKey(name: 'connected_switches')
      required final int connectedSwitches,
      required final Map<String, Switch> switches}) = _$SwitchStatusImpl;

  factory _SwitchStatus.fromJson(Map<String, dynamic> json) =
      _$SwitchStatusImpl.fromJson;

  @override
  @JsonKey(name: 'connected_switches')
  int get connectedSwitches;
  @override
  Map<String, Switch> get switches;

  /// Create a copy of SwitchStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwitchStatusImplCopyWith<_$SwitchStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Switch _$SwitchFromJson(Map<String, dynamic> json) {
  return _Switch.fromJson(json);
}

/// @nodoc
mixin _$Switch {
  @JsonKey(name: 'switch_positions')
  Map<String, int> get switchPositions => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
  double get lastUpdateSecondsAgo => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  bool get connected => throw _privateConstructorUsedError;

  /// Serializes this Switch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Switch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwitchCopyWith<Switch> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwitchCopyWith<$Res> {
  factory $SwitchCopyWith(Switch value, $Res Function(Switch) then) =
      _$SwitchCopyWithImpl<$Res, Switch>;
  @useResult
  $Res call(
      {@JsonKey(name: 'switch_positions') Map<String, int> switchPositions,
      @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
      double lastUpdateSecondsAgo,
      String name,
      int status,
      bool connected});
}

/// @nodoc
class _$SwitchCopyWithImpl<$Res, $Val extends Switch>
    implements $SwitchCopyWith<$Res> {
  _$SwitchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Switch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? switchPositions = null,
    Object? lastUpdateSecondsAgo = null,
    Object? name = null,
    Object? status = null,
    Object? connected = null,
  }) {
    return _then(_value.copyWith(
      switchPositions: null == switchPositions
          ? _value.switchPositions
          : switchPositions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastUpdateSecondsAgo: null == lastUpdateSecondsAgo
          ? _value.lastUpdateSecondsAgo
          : lastUpdateSecondsAgo // ignore: cast_nullable_to_non_nullable
              as double,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwitchImplCopyWith<$Res> implements $SwitchCopyWith<$Res> {
  factory _$$SwitchImplCopyWith(
          _$SwitchImpl value, $Res Function(_$SwitchImpl) then) =
      __$$SwitchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'switch_positions') Map<String, int> switchPositions,
      @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
      double lastUpdateSecondsAgo,
      String name,
      int status,
      bool connected});
}

/// @nodoc
class __$$SwitchImplCopyWithImpl<$Res>
    extends _$SwitchCopyWithImpl<$Res, _$SwitchImpl>
    implements _$$SwitchImplCopyWith<$Res> {
  __$$SwitchImplCopyWithImpl(
      _$SwitchImpl _value, $Res Function(_$SwitchImpl) _then)
      : super(_value, _then);

  /// Create a copy of Switch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? switchPositions = null,
    Object? lastUpdateSecondsAgo = null,
    Object? name = null,
    Object? status = null,
    Object? connected = null,
  }) {
    return _then(_$SwitchImpl(
      switchPositions: null == switchPositions
          ? _value._switchPositions
          : switchPositions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      lastUpdateSecondsAgo: null == lastUpdateSecondsAgo
          ? _value.lastUpdateSecondsAgo
          : lastUpdateSecondsAgo // ignore: cast_nullable_to_non_nullable
              as double,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      connected: null == connected
          ? _value.connected
          : connected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwitchImpl implements _Switch {
  const _$SwitchImpl(
      {@JsonKey(name: 'switch_positions')
      required final Map<String, int> switchPositions,
      @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
      required this.lastUpdateSecondsAgo,
      required this.name,
      required this.status,
      required this.connected})
      : _switchPositions = switchPositions;

  factory _$SwitchImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwitchImplFromJson(json);

  final Map<String, int> _switchPositions;
  @override
  @JsonKey(name: 'switch_positions')
  Map<String, int> get switchPositions {
    if (_switchPositions is EqualUnmodifiableMapView) return _switchPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_switchPositions);
  }

  @override
  @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
  final double lastUpdateSecondsAgo;
  @override
  final String name;
  @override
  final int status;
  @override
  final bool connected;

  @override
  String toString() {
    return 'Switch(switchPositions: $switchPositions, lastUpdateSecondsAgo: $lastUpdateSecondsAgo, name: $name, status: $status, connected: $connected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwitchImpl &&
            const DeepCollectionEquality()
                .equals(other._switchPositions, _switchPositions) &&
            (identical(other.lastUpdateSecondsAgo, lastUpdateSecondsAgo) ||
                other.lastUpdateSecondsAgo == lastUpdateSecondsAgo) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.connected, connected) ||
                other.connected == connected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_switchPositions),
      lastUpdateSecondsAgo,
      name,
      status,
      connected);

  /// Create a copy of Switch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwitchImplCopyWith<_$SwitchImpl> get copyWith =>
      __$$SwitchImplCopyWithImpl<_$SwitchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwitchImplToJson(
      this,
    );
  }
}

abstract class _Switch implements Switch {
  const factory _Switch(
      {@JsonKey(name: 'switch_positions')
      required final Map<String, int> switchPositions,
      @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
      required final double lastUpdateSecondsAgo,
      required final String name,
      required final int status,
      required final bool connected}) = _$SwitchImpl;

  factory _Switch.fromJson(Map<String, dynamic> json) = _$SwitchImpl.fromJson;

  @override
  @JsonKey(name: 'switch_positions')
  Map<String, int> get switchPositions;
  @override
  @JsonKey(name: 'last_update_seconds_ago', defaultValue: 0.0)
  double get lastUpdateSecondsAgo;
  @override
  String get name;
  @override
  int get status;
  @override
  bool get connected;

  /// Create a copy of Switch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwitchImplCopyWith<_$SwitchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
