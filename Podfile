platform :ios, '26.0'
use_frameworks!

target 'TheMovie' do
  pod 'Kingfisher', '~> 7.0'
  pod 'Alamofire', '~> 5.8'
  pod 'SkeletonView', '~> 1.30'
  pod 'Hero', '~> 1.6'

  pod 'NetworkKit',     :path => 'Modules/NetworkKit'
  pod 'UIComponentKit', :path => 'Modules/UIComponentKit'
  pod 'HomeKit',        :path => 'Modules/HomeKit'
  pod 'SearchKit',      :path => 'Modules/SearchKit'
  pod 'FavoritesKit',   :path => 'Modules/FavoritesKit'
  pod 'DetailKit',      :path => 'Modules/DetailKit'
  pod 'ReviewKit',      :path => 'Modules/ReviewKit'
end

target 'TheMovieTests' do
  inherit! :search_paths
  pod 'Nimble', '~> 13.0'
  pod 'Quick', '~> 7.0'
  pod 'NetworkKit',     :path => 'Modules/NetworkKit'
  pod 'HomeKit',        :path => 'Modules/HomeKit'
  pod 'SearchKit',      :path => 'Modules/SearchKit'
  pod 'FavoritesKit',   :path => 'Modules/FavoritesKit'
  pod 'DetailKit',      :path => 'Modules/DetailKit'
  pod 'ReviewKit',      :path => 'Modules/ReviewKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.user_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
    aggregate_target.user_project.save
  end

  pods_the_movie = Dir.glob('Pods/Target Support Files/Pods-TheMovie/Pods-TheMovie.*.xcconfig')
  pods_the_movie.each do |path|
    contents = File.read(path)
    include_line = '#include? "../../../Config.xcconfig"'
    next if contents.include?(include_line)
    File.write(path, "#{include_line}\n#{contents}")
  end
end
