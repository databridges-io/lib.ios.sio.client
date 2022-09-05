#
#        DataBridges Swift client Library targeting iOS
#        https:#www.databridges.io/
#
#
#
#        Copyright 2022 Optomate Technologies Private Limited.
#
#        Licensed under the Apache License, Version 2.0 (the "License");
#        you may not use this file except in compliance with the License.
#        You may obtain a copy of the License at
#
#            http:#www.apache.org/licenses/LICENSE-2.0
#
#        Unless required by applicable law or agreed to in writing, software
#        distributed under the License is distributed on an "AS IS" BASIS,
#        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#        See the License for the specific language governing permissions and
#        limitations under the License.
#

#
# Be sure to run `pod lib lint dbridges.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DatabridgesSwiftClient'
  s.version          = '2.0.2'
  s.summary          = 'Databridges Swift client Library targeting iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
DataBridges makes it easy for connected devices and applications to communicate with each other in realtime in an efficient, fast, reliable and trust-safe manner. Databridges Swift client library (targeting iOS) allows you to easily add realtime capabilities to your applications in record time.
                       DESC

  s.homepage         = 'https://github.com/databridges-io/lib.ios.sio.client'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = 'APACHE 2'
  s.author           = { "Optomate Technologies Private Limited." => "tech@optomate.io" }
  s.source           = { git: "https://github.com/databridges-io/lib.ios.sio.client.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/databridges-io

  s.ios.deployment_target = '9.0'

  s.source_files = 'dbridges/Classes/**/*'
  
  # s.resource_bundles = {
  #   'dbridges' => ['dbridges/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
