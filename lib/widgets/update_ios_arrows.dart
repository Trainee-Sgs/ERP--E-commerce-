import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (!directory.existsSync()) return;

  for (final file in directory.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;

    String content = file.readAsStringSync();
    
    if (content.contains('Icons.arrow_back,')) {
      content = content.replaceAll('Icons.arrow_back,', 'Icons.arrow_back_ios_new,');
      file.writeAsStringSync(content);
      print('Updated iOS back arrow in ${file.path}');
    }
  }
}
