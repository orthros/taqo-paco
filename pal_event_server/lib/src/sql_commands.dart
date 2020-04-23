const createAlarmsTable = '''
create table alarms (
  _id integer primary key autoincrement,
  json text
);''';

const createNotificationsTable = '''
create table notifications (
  _id integer primary key autoincrement,
  alarm_time integer, 
  experiment_id integer, 
  notice_count integer, 
  timeout_millis integer, 
  notification_source text, 
  message text, 
  experiment_group_name text, 
  action_trigger_id integer, 
  action_id integer, 
  action_trigger_spec_id integer, 
  snooze_time integer, 
  snooze_count integer
);''';

const createEventsTable = '''
create table events (
  _id integer primary key autoincrement,
  experiment_id integer, 
  experiment_server_id integer, 
  experiment_name text, 
  experiment_version integer, 
  schedule_time text, 
  response_time text, 
  uploaded integer, 
  group_name text, 
  action_trigger_id integer, 
  action_trigger_spec_id integer, 
  action_id integer
);''';

const createOutputsTable = '''
create table outputs (
  _id integer primary key autoincrement,
  event_id integer,
  text text,
  answer text
);''';

const insertEventCommand = '''
insert into events (
  experiment_id,
  experiment_server_id,
  experiment_name,
  experiment_version,
  schedule_time,
  response_time,
  uploaded,
  group_name,
  action_trigger_id,
  action_trigger_spec_id,
  action_id
) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
)''';

const insertOutputCommand = '''
insert into outputs (
  event_id,
  text,
  answer
) values (
  ?, ?, ?
);''';