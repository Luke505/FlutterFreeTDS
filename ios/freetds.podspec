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
  s.platform = :ios, '12.0'
  s.library = 'c++'

  s.preserve_paths = 'FreeTDS.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework FreeTDS' }
  s.vendored_frameworks = 'FreeTDS.framework'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
