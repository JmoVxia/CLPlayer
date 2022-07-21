source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
platform :ios, '10.0'
#use_frameworks!
use_modular_headers!
inhibit_all_warnings!
install! 'cocoapods', :deterministic_uuids => false

target 'CLPlayer' do
    inhibit_all_warnings!
    pod 'SnapKit'
    pod 'SwiftFormat/CLI'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 10.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end
end

