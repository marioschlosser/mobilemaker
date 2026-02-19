#if DEBUG
import Foundation
import Network

/// Lightweight HTTP server for test automation. Runs only in DEBUG builds.
/// Accepts commands via curl and forwards them to the game via `TestableGame`.
///
/// Endpoints:
///   GET  /ping              → {"status":"ok","game":"..."}
///   GET  /state             → current game state
///   GET  /actions           → list of available actions
///   POST /tap               → {"x":200,"y":400}  → triggers performTap
///   POST /action            → {"name":"fire","parameters":{"weapon":"missile"}}
final class TestHarnessServer {
    private var listener: NWListener?
    private weak var game: TestableGame?
    private let port: UInt16

    init(port: UInt16 = 7483) {
        self.port = port
    }

    func start(game: TestableGame) {
        self.game = game

        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true

        do {
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            print("[TestHarness] Failed to create listener: \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("[TestHarness] Listening on port \(self.port)")
                self.writePortFile()
            case .failed(let error):
                print("[TestHarness] Listener failed: \(error)")
            default:
                break
            }
        }

        listener?.start(queue: .main)
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    // MARK: - Port Discovery

    private func writePortFile() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let portFile = docs.appendingPathComponent("testharness_port.txt")
        try? "\(port)".write(to: portFile, atomically: true, encoding: .utf8)
    }

    // MARK: - Connection Handling

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
            guard let self = self, let data = data, error == nil else {
                connection.cancel()
                return
            }

            let request = String(data: data, encoding: .utf8) ?? ""
            let response = self.route(request)
            let httpResponse = self.httpResponse(json: response)

            connection.send(content: httpResponse.data(using: .utf8), completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    // MARK: - Routing

    private func route(_ raw: String) -> [String: Any] {
        let lines = raw.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            return ["error": "empty request"]
        }

        let parts = requestLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            return ["error": "malformed request"]
        }

        let method = parts[0]
        let path = parts[1]

        // Parse JSON body for POST requests
        var body: [String: Any] = [:]
        if method == "POST", let bodyStart = raw.range(of: "\r\n\r\n") {
            let bodyStr = String(raw[bodyStart.upperBound...])
            if let bodyData = bodyStr.data(using: .utf8),
               let parsed = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
                body = parsed
            }
        }

        switch path {
        case "/ping":
            return ping()
        case "/state":
            return state()
        case "/actions":
            return actions()
        case "/tap":
            return tap(body: body)
        case "/action":
            return action(body: body)
        default:
            return ["error": "unknown endpoint: \(path)"]
        }
    }

    // MARK: - Endpoints

    private func ping() -> [String: Any] {
        return [
            "status": "ok",
            "game": game?.gameName ?? "unknown",
            "port": port
        ]
    }

    private func state() -> [String: Any] {
        guard let game = game else { return ["error": "no game connected"] }
        return ["state": game.queryState()]
    }

    private func actions() -> [String: Any] {
        guard let game = game else { return ["error": "no game connected"] }
        return ["actions": game.availableActions]
    }

    private func tap(body: [String: Any]) -> [String: Any] {
        guard let game = game else { return ["error": "no game connected"] }

        guard let x = body["x"] as? Double,
              let y = body["y"] as? Double else {
            return ["error": "missing x/y coordinates", "usage": "POST /tap {\"x\":200,\"y\":400}"]
        }

        let point = CGPoint(x: x, y: y)
        let handled = game.performTap(at: point)

        return [
            "handled": handled,
            "tap": ["x": x, "y": y],
            "state": game.queryState()
        ]
    }

    private func action(body: [String: Any]) -> [String: Any] {
        guard let game = game else { return ["error": "no game connected"] }

        guard let name = body["name"] as? String else {
            return ["error": "missing action name", "usage": "POST /action {\"name\":\"fire\",\"parameters\":{}}"]
        }

        let parameters = body["parameters"] as? [String: Any] ?? [:]
        let result = game.performAction(name, parameters: parameters)

        return [
            "action": name,
            "result": result,
            "state": game.queryState()
        ]
    }

    // MARK: - HTTP Formatting

    private func httpResponse(json: [String: Any]) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys])) ?? Data()
        let jsonStr = String(data: data, encoding: .utf8) ?? "{}"

        return """
        HTTP/1.1 200 OK\r
        Content-Type: application/json\r
        Content-Length: \(data.count)\r
        Connection: close\r
        Access-Control-Allow-Origin: *\r
        \r
        \(jsonStr)
        """
    }
}
#endif
