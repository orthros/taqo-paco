import 'dart:io';

import 'package:path/path.dart' as path;

import '../storage/local_file_storage.dart';

class DartFileStorage implements ILocalFileStorage {
  final _localFileName;

  // These should match whatever Flutter path_provider returns
  // Is there a better way to keep them in sync?
  static Directory getLocalStorageDir() {
    if (Platform.isLinux) {
      return Directory('${Platform.environment['HOME']}/.local/share/taqo')
        ..createSync(recursive: true);
    } else if (Platform.isMacOS) {
      return Directory(
          '${Platform.environment['HOME']}/Library/Containers/com.taqo.survey.taqoClient/Data/Library/Application Support/com.taqo.survey.taqoClient')
        ..createSync(recursive: true);
    }

    throw UnsupportedError('Only supported on desktop platforms');
  }

  Future<Directory> get localStorageDir async => getLocalStorageDir();

  Future<String> get localPath async => (await localStorageDir).path;

  Future<File> get localFile async {
    final f = File(path.join(await localPath, _localFileName));
    if (!(await f.exists())) {
      await f.create();
    }
    await Process.run('chmod', [
      '0600',
      f.path,
    ]);
    return f;
  }

  DartFileStorage(this._localFileName);

  Future clear() async {
    final file = await localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
