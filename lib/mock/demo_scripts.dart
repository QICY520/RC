/// Demo data for the workspace flow.
class DemoScript {
  DemoScript._();

  static const List<String> initialCode = [
    '// 等待指令输入...',
  ];

  static const String voiceInputText = '如果妈妈回家，就打开灯';

  static const List<String> generatedCode = [
    'code',
    'Dart',
    'if (Mom.isArriving) {',
    '  Robot.dance();',
    "  Light.turnOn(color: 'warm');",
    '}',
  ];

  static const String aiResponse = '逻辑已生成！我检测到了 [妈妈] 和 [开灯] 的意图。';
}

