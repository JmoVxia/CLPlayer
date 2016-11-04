Pod::Spec.new do |s|
    s.name         = ‘CLPlayer’
    s.version      = ‘1.0.0’
    s.summary      = 'An easy way to use Player’
    s.homepage     = 'https://github.com/JmoVxia/CLPlayer'
    s.license      = 'MIT'
    s.authors      = {‘JmoVxia’ => ’269968846@qq.com'}
    s.platform     = :ios, ‘8.0’
    s.source       = {:git => 'https://github.com/JmoVxia/CLPlayer.git', :tag => s.version}
    s.source_files = 'CLPlayerDemo/CLPlayerDemo/Player*.{h,m}'
    s.resource     = 'CLPlayerDemo/CLPlayerDemo/Player/Resources*.{png}’
    s.requires_arc = true
end