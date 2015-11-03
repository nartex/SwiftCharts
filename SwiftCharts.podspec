Pod::Spec.new do |s|
  s.name = "SwiftCharts"
  s.version = "0.3.1"
  s.summary = "extensible, flexible charts library for iOS"
  s.homepage = "https://github.com/nartex/SwiftCharts"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = "Ivan Schuetz"
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/nartex/SwiftCharts.git", :head }
  s.source_files = 'SwiftCharts/*.swift', 'SwiftCharts/**/*.swift'
  s.frameworks = "Foundation", "UIKit", "CoreGraphics"
end
