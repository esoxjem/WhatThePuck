import Foundation

enum MessageEngineProvider {
    private static var cachedEngine: MessageEngine?

    static var shared: MessageEngine {
        if let engine = cachedEngine {
            return engine
        }
        let engine = loadEngine()
        cachedEngine = engine
        return engine
    }

    private static func loadEngine() -> MessageEngine {
        guard let url = Bundle.main.url(forResource: "rules", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let engine = try? MessageEngine(jsonData: data) else {
            return createFallbackEngine()
        }
        return engine
    }

    private static func createFallbackEngine() -> MessageEngine {
        let fallbackJSON = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": ["Let's pull a shot."]
                }
            ]
        }
        """
        return try! MessageEngine(jsonData: Data(fallbackJSON.utf8))
    }
}
