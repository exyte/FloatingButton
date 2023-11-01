Pod::Spec.new do |s|
  s.name             = "FloatingButton"
  s.version          = "1.2.2"
  s.summary          = "Easily customizable floating button menu created with SwiftUI."

  s.homepage         = 'https://github.com/exyte/FloatingButton.git'
  s.license          = 'MIT'
  s.author           = { 'exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/FloatingButton.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.watchos.deployment_target = '10.0'
  
  s.requires_arc     = true
  s.swift_version    = '5.1'

  s.source_files = [
     'Sources/*.h',
     'Sources/*.swift',
     'Sources/**/*.swift'
  ]
end
