import Foundation

private class OverrideBundleFinder {}

extension Foundation.Bundle {
    static var overrideModule: Bundle = {
        let bundleName = "SkyTestFoundation_client-lib-ios-test-foundation"
        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,
            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: OverrideBundleFinder.self).resourceURL,
            Bundle(for: OverrideBundleFinder.self).resourceURL?.deletingLastPathComponent(),
            /* For command-line tools. */
            Bundle.main.bundleURL,
            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: OverrideBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent(),
            Bundle(for: OverrideBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent()
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle. BUG REFERENCE: https://developer.apple.com/forums/thread/664295")
    }()
}
