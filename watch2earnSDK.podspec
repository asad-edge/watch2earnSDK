#
# Be sure to run `pod lib lint watch2earnSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'watch2earnSDK'
  s.version          = '0.2.9'
  s.summary          = 'watch2earnSDK for Apple TV apps to enable live streaming, earning tokens, and gamified features.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'Introducing Watch2Earn Framework – a powerful Apple TV framework designed to enhance live streaming experiences and enable users to earn tokens while watching their favorite content. With Watch2Earn, developers can seamlessly integrate interactive features and gamification elements into live streams, creating an engaging and rewarding environment for viewers.'
                       DESC

  s.homepage         = 'https://github.com/asad-edge/watch2earnSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'asad-edge' => 'asad@edgevideo.com' }
  s.source           = { :git => 'https://github.com/asad-edge/watch2earnSDK.git', :tag => s.version.to_s }
  s.social_media_url = 'https://t.me/EDGEVideo'

  s.tvos.deployment_target = '14.0'

  s.source_files = 'Source/**/*.swift'
  s.resources = ['Source/**/*.xib', 'Source/**/*.png', 'Source/**/*.mp3', 'Source/**/*.gif', 'Source/**/*.otf', 'Source/**/*.storyboard', 'Source/**/*.xcassets']
  s.swift_versions = '5.0'
  s.platforms = {
              "tvos": "14.0"
}
  
  #  s.resource_bundles = {
  #    'watch2earnSDK' => ['Source/**/*.png', 'Source/**/*.mp3','Source/**/*.otf' , 'Source/**/*.xib', 'Source/**/*.storyboard']
  #  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
