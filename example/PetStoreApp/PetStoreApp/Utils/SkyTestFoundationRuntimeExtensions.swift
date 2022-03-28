//
// This is a necessary boilerplate file needed to make Sky Test Foundation UI Tests work as intended
// Just copy this and add target membership to app and UI tests
//
import Foundation

extension URL {
    func replaceHostnameWithLocalhostIfUITestIsRunning() -> URL {
        guard TestsHelper.isUITestRunning else { return self }
        #if DEBUG
        return replaceHostnameWithLocalhost(port: TestsHelper.mockServerHttpPort)
        #else
        return self
        #endif
    }
    
    func replaceHostnameWithLocalhost(port: Int = 8080) -> URL {
        return URL(string: absoluteString.replacingOccurrences(of: host ?? "", with: "127.0.0.1:\(port)")
            .replacingOccurrences(of: scheme!, with: "http"))!
    }
}

struct TestsHelper {
    static let isUITestRunning = CommandLine.arguments.contains("-enable-uitest")  // TODO C8 TestSuiteKeys NO Release

    #if DEBUG
    static let mockServerHttpPort: Int = UserDefaults.standard.integer(forKey: TestSuiteKeys.serverHttpPort.rawValue)
    #endif
}

#if DEBUG
enum TestSuiteKeys: String {
    case prefixTest = "test."
    case serverHttpPort = "server-http-port"
    case persistence
    case deeplink
    static let enableUITestArg = "-enable-uitest"
}

extension TestSuiteKeys {
    func argValue() -> Bool {
        UserDefaults.standard.bool(forKey: self.rawValue)
    }

    func argValue() -> String? {
        UserDefaults.standard.string(forKey: self.rawValue)
    }

    func buildArg(suffix: String = "", value: String) -> [String] {
        ["-" + self.rawValue + suffix, value]
    }
}
#endif
