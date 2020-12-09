#!/bin/bash
xcodebuild test -disableAutomaticPackageResolution -project Demos/DemoMacOS/DemoMacOS.xcodeproj -scheme DemoMacOSUITests  -clonedSourcePackagesDirPath SourcePackages
xcodebuild test -disableAutomaticPackageResolution -project Demos/DemoIOS/DemoIOS.xcodeproj -scheme DemoIOSUITests -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11' -clonedSourcePackagesDirPath SourcePackages
