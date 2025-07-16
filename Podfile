source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
platform :ios, '15.0'
#use_frameworks!
use_modular_headers!
inhibit_all_warnings!
install! 'cocoapods', :deterministic_uuids => false

target 'CLPlayer' do
    inhibit_all_warnings!
    pod 'SnapKit'
    pod 'SwiftFormat/CLI'
    pod 'LookinServer', :subspecs => ['Swift'], :configurations => ['Debug']
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end

