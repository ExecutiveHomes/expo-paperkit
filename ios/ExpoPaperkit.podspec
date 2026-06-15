Pod::Spec.new do |s|
  s.name           = 'ExpoPaperkit'
  s.version        = '0.1.0'
  s.summary        = 'Apple PaperKit markup experience for Expo/React Native'
  s.description    = 'Add drawings, shapes, and a consistent markup experience to your app — powered by Apple PaperKit (iOS 26+ / macOS 26+) and PencilKit.'
  s.author         = 'Gregory Moskaliuk'
  s.homepage       = 'https://github.com/hryhoriiK97/expo-paperkit'
  s.license        = 'MIT'
  s.platforms      = {
    :ios => '16.4',
    :osx => '14.0'
  }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '$(inherited) -weak_framework PaperKit -weak_framework PencilKit',
    'SWIFT_STRICT_CONCURRENCY' => 'minimal',
  }

  s.weak_frameworks = ['PaperKit', 'PencilKit']
  s.source_files = "**/*.swift"
end
