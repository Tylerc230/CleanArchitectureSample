echo "iOS tests clean"
time xcodebuild clean test -quiet -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.1' -scheme CleanArchitectureSample
echo "incremental"
time xcodebuild test -quiet -destination 'platform=iOS Simulator,name=iPhone 7,OS=11.1' -scheme CleanArchitectureSample
echo "macOS tests"
time xcodebuild clean test  -quiet -destination 'platform=macOS' -scheme CleanArchitectureCLI
echo "incremental"
time xcodebuild test  -quiet -destination 'platform=macOS' -scheme CleanArchitectureCLI
