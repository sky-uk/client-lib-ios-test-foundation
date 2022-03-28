//
// This is a necessary boilerplate file needed to make Sky Test Foundation UI Tests work as intended
// Just copy this and add target membership to app and UI tests
//
import Foundation

extension URL {
    func replaceHostnameWithLocalhostIfUITestIsRunning() -> URL {
        guard CommandLine.arguments.contains(TestSuiteKeys.enableUITestArg) else { return self }
        #if DEBUG
        return replaceHostnameWithLocalhost()
        #else
        return self
        #endif
    }
    
    func replaceHostnameWithLocalhost(port: Int = 8080) -> URL {
        return URL(string: absoluteString.replacingOccurrences(of: host ?? "", with: "127.0.0.1:\(port)")
            .replacingOccurrences(of: scheme!, with: "http"))!
    }
}

#if DEBUG
struct TestSuiteKeys {
    static let enableUITestArg = "-enable-uitest"
}
#endif
