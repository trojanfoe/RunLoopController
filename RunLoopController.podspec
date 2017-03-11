Pod::Spec.new do |s|
  s.name             = "RunLoopController"
  s.version          = "0.1.0"
  s.summary          = "Objective-C Run Loop controller useful for command line utilities"

  s.homepage         = "https://github.com/trojanfoe/RunLoopController"
  s.license          = 'MIT'
  s.author           = { "Andy Duplain" => "trojanfoe@gmail.com" }
  s.source           = { :git => "https://github.com/trojanfoe/RunLoopController.git", :branch => 'master' }
  s.social_media_url = 'https://twitter.com/trojanfoe'

  s.platform     = :osx, '10.6'
  s.requires_arc = true
  s.frameworks = 'Foundation'
  s.source_files = 'RunLoopController.{h,m}'
end
