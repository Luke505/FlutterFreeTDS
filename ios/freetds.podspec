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
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.library = 'c++'

  s.preserve_paths = 'FreeTDSKit.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FreeTDSKit' }
  s.vendored_frameworks = 'FreeTDSKit.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
