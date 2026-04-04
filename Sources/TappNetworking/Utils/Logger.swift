public final class TappLog {
    public static func logError(_ error: Error, environment: Environment, context: String? = nil) {
        guard environment == .sandbox else { return }
        print("Tapp ------------------")
        if let context {
            print("Context: \(context)")
        }
        print("Error: \(error.localizedDescription)")
    }

    public static func logInfo(message: String, environment: Environment, context: String? = nil) {
        guard environment == .sandbox else { return }
        print("Tapp ------------------")
        if let context {
            print("Context: \(context)")
        }
        print("Info: \(message)")
    }
}
