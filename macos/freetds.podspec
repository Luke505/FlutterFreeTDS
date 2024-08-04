Pod::Spec.new do |s|
  s.name             = 'freetds'
  s.version          = '1.0.0'
  s.summary          = 'FreeTDS SDK for iOS mobile devices.'
  s.description      = 'FreeTDS package'
  s.homepage         = 'developerpass.net'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DeveloperPass' => 'developerpass.net' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.library = 'c++'

  s.preserve_paths = 'FreeTDS-macOS.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FreeTDS-macOS' }
  s.vendored_frameworks = 'FreeTDS-macOS.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
