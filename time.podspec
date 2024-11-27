Pod::Spec.new do |s|

  s.name             = "Time"
  s.version          = "1.0.2"
  s.summary          = "Time is a Swift package that makes it easy to perform robust and type-safe date and time calculations."
  
  s.homepage         = "https://github.com/davedelong/time"
  s.license          = 'MIT'
  s.author           = { "Dave Delong" => "davedelong.com" }
  s.source           = { :git => "https://github.com/davedelong/time.git", :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = "15.0"
  s.swift_versions = "5.7"
  s.framework    = "Foundation"
  s.pod_target_xcconfig = {
    "ENABLE_TESTING_SEARCH_PATHS" => "YES",
  }
  s.source_files = "Sources/**/*.swift"

end