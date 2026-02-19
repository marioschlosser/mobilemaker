import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    #if DEBUG
    var testHarness: TestHarnessServer?
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let gameVC = GameViewController()
        window.rootViewController = gameVC
        window.makeKeyAndVisible()
        self.window = window

        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let scene = gameVC.gameScene {
                self.testHarness = TestHarnessServer()
                self.testHarness?.start(game: scene)
            }
        }
        #endif

        return true
    }
}
