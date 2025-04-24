#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'contactos_ios'
  s.version          = '1.0.0'
  s.summary          = "A Flutter plugin to retrieve and manage contacts on iOS devices"
  s.description      = <<-DESC
  A Flutter plugin to retrieve and manage contacts on iOS devices.
                       DESC
  s.homepage         = 'https://github.com/ziqq/contactos/contactos_ios'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Anton Ustinoff' => 'a.a.ustinoff@gmail.com' }
  s.source           = { :http => 'https://github.com/ziqq/contactos/contactos_ios' }
  s.public_header_files = 'contactos_ios/Sources/contactos_ios/**/*.h'
  s.source_files = 'contactos_ios/Sources/contactos_ios/**/*.{swift,m,h}'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
 }
 s.swift_version = '5.0'
 s.resource_bundles = {'contactos_ios_privacy' => ['contactos_ios/Sources/contactos_ios/Resources/PrivacyInfo.xcprivacy']}
end

