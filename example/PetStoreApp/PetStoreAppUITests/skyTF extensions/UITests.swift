import XCTest
import SkyTestFoundation

class UITests: SkyUITestCase {

    @discardableResult
    func appLaunch(_ serverHttpPort: Int = 8080, handleSystemAlert: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        var launchArguments = [TestSuiteKeys.enableUITestArg]
        launchArguments.append(contentsOf: TestSuiteKeys.serverHttpPort.buildArg(value: "\(serverHttpPort)"))

        debugPrint("UI Tests Launch Arguments")
        launchArguments.forEach { (arg) in
            debugPrint(arg)
        }

        let testPlanArgs = CommandLine.arguments
        app.launchArguments = launchArguments + testPlanArgs

        app.launch()
        if !handleSystemAlert {
            addUIInterruptionMonitor(withDescription: "System alerts") { alert in
                let allowButton = alert.buttons["Allow"]
                if allowButton.exists {
                    allowButton.tap()
                    return true
                }
                let consentiButton = alert.buttons["Consenti"]
                if consentiButton.exists {
                    consentiButton.tap()
                    return true
                }
                let notNowButton = alert.buttons["Not Now"]
                if notNowButton.exists {
                    notNowButton.tap()
                    return true
                }
                let nonOraButton = alert.buttons["Non ora"]
                if nonOraButton.exists {
                    nonOraButton.tap()
                    return true
                }
                return false
            }
        }
        return app
    }

}
