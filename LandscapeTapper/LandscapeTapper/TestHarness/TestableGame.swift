#if DEBUG
import CoreGraphics
import Foundation

/// Protocol that games implement to expose their state and actions to the test harness.
/// Conformance should be added via a `#if DEBUG` extension on `GameScene`.
protocol TestableGame: AnyObject {
    /// Returns the current game state as a JSON-serializable dictionary.
    /// Should include score, screen/scene name, and any game-specific state.
    func queryState() -> [String: Any]

    /// Triggers the same code path as a real touch at the given point (in scene coordinates).
    /// Returns true if the tap was handled.
    func performTap(at point: CGPoint) -> Bool

    /// Executes a named game action with optional parameters.
    /// Returns a result dictionary (always includes updated state).
    func performAction(_ name: String, parameters: [String: Any]) -> [String: Any]

    /// Self-describing catalog of available actions for auto-discovery.
    var availableActions: [[String: Any]] { get }

    /// The name of the game (used in /ping response).
    var gameName: String { get }
}
#endif
