/// Static snippets to mimic generated code blocks.
const List<String> demoSnippets = [
  '''
function bootstrapCore() {
  const registry = createRegistry();
  registry.enable("ai-stream");
  return registry.launch();
}
  ''',
  '''
class QuantumDriver {
  constructor(bus) {
    this.bus = bus;
  }

  tick(frame) {
    this.bus.emit("frame", frame);
  }
}
  ''',
  '''
// pipeline.yaml
stages:
  - lint
  - test
  - deploy:
      target: "edge-eu-01"
  ''',
];

