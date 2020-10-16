import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'action_trigger.dart';
import 'experiment.dart';
import 'experiment_group.dart';
import 'paco_notification_action.dart';

part 'action_specification.g.dart';

@JsonSerializable()
class ActionSpecification implements Comparable<ActionSpecification> {
  DateTime time;
  DateTime timeUTC;
  Experiment experiment;
  ExperimentGroup experimentGroup;

  ActionTrigger actionTrigger;

  PacoNotificationAction action;
  int actionTriggerSpecId;

  @visibleForTesting
  ActionSpecification.empty();

  ActionSpecification(this.time, this.experiment, this.experimentGroup,
      this.actionTrigger, this.action, this.actionTriggerSpecId) {
    if (action != null && action.timeout == null) {
      action.timeout = 59;
    }
    timeUTC = time.toUtc();
  }

  factory ActionSpecification.fromJson(Map<String, dynamic> json) =>
      _$ActionSpecificationFromJson(json);

  Map<String, dynamic> toJson() => _$ActionSpecificationToJson(this);

  @override
  int compareTo(ActionSpecification other) => time.compareTo(other.time);

  @override
  String toString() =>
      '${experiment.title} - ${experimentGroup.name} - ${actionTriggerSpecId} - '
      '${time.toIso8601String()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionSpecification &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          experiment.id == other.experiment.id &&
          experimentGroup.name == other.experimentGroup.name;

  @override
  int get hashCode =>
      time.hashCode ^ experiment.id.hashCode ^ experimentGroup.name.hashCode;
}
