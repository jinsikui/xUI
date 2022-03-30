#
#  Be sure to run `pod spec lint xUI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'xUI'
  s.version          = '1.0.0.0'
  s.summary          = 'UI基础组件库'

  s.description      = <<-DESC
    UI基础组件库
                       DESC

  s.homepage         = 'https://github.com/jinsikui/xUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jinsikui' => '1811652374@qq.com' }
  s.source           = { :git => 'https://github.com/jinsikui/xUI.git'}
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/Classes/xUI.h'
  s.dependency 'Masonry'
  s.dependency 'MJRefresh'
  s.dependency 'PromisesObjC'
  s.dependency 'SDWebImage'
  s.dependency 'KVOController'
  
  s.subspec 'Views' do |sv|
    sv.source_files = 'Source/Classes/Views/*'
    sv.subspec 'PopViewBase' do |pv|
      pv.source_files = 'Source/Classes/Views/PopViewBase/*'
    end
  end
  s.subspec 'ViewControllers' do |svc|
    svc.source_files = 'Source/Classes/ViewControllers/*'
  end
  s.subspec 'Helpers' do |sh|
    sh.source_files = 'Source/Classes/Helpers/*'
  end

end
