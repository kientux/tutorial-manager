#
# Be sure to run `pod lib lint TutorialManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TutorialManager'
  s.version          = '1.0.8'
  s.summary          = 'A tool for showing tutorial.'

  s.description      = <<-DESC
  A tool for showing tutorial..
                       DESC

  s.homepage         = 'https://github.com/kientux/tutorial-manager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kientux' => 'ntkien93@gmail.com' }
  s.source           = { :git => 'https://github.com/kientux/tutorial-manager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.5'

  s.source_files = 'Sources/TutorialManager/**/*.swift'
  s.resource_bundles = {
    "TutorialManager" => ["Sources/TutorialManager/Resources/*"]
  }
end
