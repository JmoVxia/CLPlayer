Pod::Spec.new do |s|

  s.name         = "CLPlayer"
  s.version      = "1.0.5"
  s.summary      = "A Player."
  s.description  = <<-DESC
		This is a player that supports full screen,use it so easy.
                      DESC
  s.homepage     = "https://github.com/JmoVxia/CLPlayer"
  s.license      = "MIT"
  s.author       = { "JmoVxia" => "610934716@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/JmoVxia/CLPlayer.git", :tag => s.version }  
  s.source_files = 'CLPlayerDemo/CLPlayerDemo/Player/*.{h,m}'
  s.resource     = 'CLPlayerDemo/CLPlayerDemo/Player/*.{bundle}'
  s.frameworks   = 'Foundation', 'UIKit','MediaPlayer'
  s.dependency 'Masonry'
  s.requires_arc = true


end
