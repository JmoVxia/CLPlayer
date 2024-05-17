Pod::Spec.new do |s|

  s.name         = 'CLPlayer'
  s.version      = '2.0.6'
  s.summary      = 'Swift版自定义AVPlayer'
  s.description  = <<-DESC
                   CLPlayer是基于系统AVPlayer封装的视频播放器.
                   * 支持Autolayout、UIStackView、Frame.
                   * 支持UITableView、UICollectionView.
                   * 支持亮度、音量调节.
                   * 支持进度调节.
                   * 支持倍数播放.
                   DESC
  s.homepage     = 'https://github.com/JmoVxia/CLPlayer'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = {'JmoVxia' => '269968846@qq.com'}
  s.social_media_url = 'https://github.com/JmoVxia'
  s.swift_versions = ['5.0']
  s.ios.deployment_target = '12.0'
  s.source       = {:git => 'https://github.com/JmoVxia/CLPlayer.git', :tag => s.version}
  s.source_files = ['CLPlayer/**/*.swift']
  s.resource     = 'CLPlayer/CLPlayer.bundle'
  s.requires_arc = true
  s.frameworks = 'UIKit','MediaPlayer'
  s.dependency 'SnapKit'

end