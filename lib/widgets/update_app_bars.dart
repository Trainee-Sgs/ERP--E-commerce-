import 'dart:io';

void main() {
  final directories = [
    'lib/product modules',
    'lib/price modules',
    'lib/customer modules',
    'lib/access module',
  ];

  for (final dirPath in directories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;

      String content = file.readAsStringSync();
      
      // Determine screen name from class name
      final RegExp classRegex = RegExp(r'class\s+([A-Za-z0-9_]+)\s+extends');
      final match = classRegex.firstMatch(content);
      String screenName = 'Ecommerce';
      if (match != null) {
        screenName = match.group(1)!;
        // Convert camel case to space-separated words
        screenName = screenName.replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m.group(1)}').trim();
        // Remove 'Screen' or 'State' at the end
        if (screenName.endsWith(' Screen')) {
          screenName = screenName.substring(0, screenName.length - 7);
        }
      }

      bool updated = false;
      
      // 1. Menu to arrow_back (only for those that go back)
      if (content.contains('icon: const Icon(Icons.menu, color: Colors.white),') && content.contains('onPressed: () => Navigator.pop(context),')) {
          content = content.replaceAll('icon: const Icon(Icons.menu, color: Colors.white),', 'icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),');
          updated = true;
      }

      // 2. 'Ecommerce' to screenName inside AppBar title
      final titleRegex = RegExp(r"title:\s*Text\(\s*'Ecommerce',");
      if (titleRegex.hasMatch(content)) {
          content = content.replaceAll(titleRegex, "title: Text('$screenName',");
          updated = true;
      }

      // 3. remove actions containing notifications
      final actionsRegex = RegExp(r'actions:\s*\[[^\]]*Icons\.notifications_none[^\]]*\]\s*,?');
      if (actionsRegex.hasMatch(content)) {
          content = content.replaceAll(actionsRegex, '');
          updated = true;
      }

      if (updated) {
          file.writeAsStringSync(content);
          print('Updated ${file.path} with title $screenName');
      }
    }
  }
}
