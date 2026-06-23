Pod::Spec.new do |s|
  s.name             = 'ReviewKit'
  s.version          = '1.0.0'
  s.summary          = 'Reviews screen for TheMovie'
  s.homepage         = 'https://github.com/themovie'
  s.license          = { :type => 'MIT' }
  s.author           = { 'TheMovie' => 'dev@themovie.app' }
  s.source           = { :git => '', :tag => s.version.to_s }
  s.ios.deployment_target = '26.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Sources/**/*.{swift}'
  s.dependency 'NetworkKit'
  s.dependency 'UIComponentKit'
  s.dependency 'Kingfisher', '~> 7.0'
  s.dependency 'SkeletonView', '~> 1.30'
end
