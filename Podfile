platform :ios, '13.0'
use_frameworks!
target 'exhibitionary' do
    pod 'SDWebImage', '~>3.7'
    pod 'GoogleMaps', '~>7.0'
    pod 'NYTPhotoViewer', '~> 1.1.0'
    pod 'AMPopTip'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
