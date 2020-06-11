import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:logging/logging.dart';
import 'package:taqo_common/model/event.dart';

import 'pal_event_helper.dart';
import 'loggers.dart';

final _logger = Logger('AppLogger');

const _queryInterval = const Duration(seconds: 1);
const _xpropCommand = 'xprop';
const _xpropGetIdArgs = ['-root', '32x', '\t\$0', '_NET_ACTIVE_WINDOW', ];

const appNameField = 'WM_CLASS';
const windowNameField = '_NET_WM_NAME';
const _xpropNameFields = [appNameField, windowNameField, ];

List<String> _xpropGetAppArgs(int windowId) {
  return ['-id', '$windowId', ] + _xpropNameFields;
}

const _invalidWindowId = -1;
String _lastResult;

/// Query xprop for the active window
void _appLoggerIsolate(SendPort sendPort) {
  final idSplitRegExp = RegExp(r'\s+');
  final fieldSplitRegExp = RegExp(r'\s+=\s+|\n');
  final appSplitRegExp = RegExp(r',\s*');

  int parseWindowId(dynamic result) {
    if (result is String) {
      final windowId = result.split(idSplitRegExp);
      if (windowId.length > 1) {
        return int.tryParse(windowId[1]) ?? _invalidWindowId;
      }
    }
    return _invalidWindowId;
  }

  Map<String, dynamic> buildResultMap(dynamic result) {
    if (result is! String) return null;
    final resultMap = <String, dynamic>{};
    final fields = result.split(fieldSplitRegExp);
    int i = 1;
    for (var name in _xpropNameFields) {
      if (i >= fields.length) break;
      if (name == appNameField) {
        final split = fields[i].split(appSplitRegExp);
        if (split.length > 1) {
          resultMap[name] = split[1].trim().replaceAll('"', '');
        } else {
          resultMap[name] = fields[i].trim().replaceAll('"', '');
        }
      } else {
        resultMap[name] = fields[i].trim().replaceAll('"', '');
      }
      i += 2;
    }
    return resultMap;
  }

  Timer.periodic(_queryInterval, (Timer _) {
    // Gets the active window ID
    Process.run(_xpropCommand, _xpropGetIdArgs).then((result) {
      // Parse the window ID
      final windowId = parseWindowId(result.stdout);
      if (windowId != _invalidWindowId) {
        // Gets the active window name
        Process.run(_xpropCommand, _xpropGetAppArgs(windowId)).then((result) {
          final res = result.stdout;
          if (res != _lastResult) {
            _lastResult = res;
            final resultMap = buildResultMap(res);
            if (resultMap != null) {
              sendPort.send(resultMap);
            }
          }
        });
      }
    });
  });
}

class AppLogger {
  static const _sendDelay = const Duration(seconds: 9);
  static final _instance = AppLogger._();

  ReceivePort _receivePort;
  Isolate _isolate;

  final _eventsToSend = <Event>[];
  bool _active = false;

  AppLogger._();

  factory AppLogger() {
    return _instance;
  }

  void stop() {
    _logger.info('Stopping AppLogger');
    _active = false;
    _isolate?.kill();
    _receivePort?.close();
  }

  void start() async {
    if (_active) return;
    _logger.info('Starting AppLogger');
    // Port for the main Isolate to receive msg from AppLogger Isolate
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_appLoggerIsolate, _receivePort.sendPort);
    _isolate.addOnExitListener(_receivePort.sendPort, response: null);
    _receivePort.listen(_listen);
    _active = true;

    Timer.periodic(_sendDelay, _sendToPal);
  }

  void _listen(dynamic data) {
    // The Isolate died
    if (data == null) {
      _receivePort.close();
      _isolate.kill();
      if (_active) {
        // Restart?
        start();
      }
      return;
    }

    if (data is Map && data.isNotEmpty) {
      createLoggerPacoEvents(data, createAppUsagePacoEvent).then((events) {
        _eventsToSend.addAll(events);
      });
    }
  }

  void _sendToPal(Timer timer) {
    List<Event> events = List.of(_eventsToSend);
    _eventsToSend.clear();
    if (events.isNotEmpty) {
      storePacoEvent(events);
    }
    if (!_active) {
      timer.cancel();
    }
  }
}

//void main() {
//  AppLogger();
//}
