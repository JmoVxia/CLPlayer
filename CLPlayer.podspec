Pod::Spec.new do |s|
    s.name         = 'CLPlayer'
    s.version      = '1.0.5'
    s.summary      = '自定义支持全屏的视频播放器'
    s.homepage     = 'https://github.com/JmoVxia/CLPlayer'
    s.license      = 'MIT'
    s.authors      = {'JmoVxia' => '269968846@qq.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/JmoVxia/CLPlayer.git', :tag => s.version}
    s.source_files = 'CLPlayer/**/*.{h,m}'
    s.resource     = 'CLPlayer/CLPlayer.bundle'
    s.framework    = 'UIKit','MediaPlayer'
    s.dependency 'Masonry' 
    s.public_header_files = 'CLPlayer/CLPlayer.h'
    s.source_files = 'CLPlayer/CLPlayer.h'
    s.requires_arc = true
end
