#
# Be sure to run `pod lib lint FOAVectors.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FOAVectors"
  s.version          = "0.1.0"
  s.summary          = "Easy rendering of Font Awesome vectors for iOS."
  s.homepage         = "https://github.com/programmingthomas/FOAVectors"
  s.license          = 'MIT'
  s.author           = { "Programming Thomas" => "programmingthomas@gmail.com" }
  s.source           = { :git => "https://github.com/programmingthomas/FOAVectors.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*.svg'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
