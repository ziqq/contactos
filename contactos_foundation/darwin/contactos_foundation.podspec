#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'contactos_foundation'
  s.version          = '0.0.1'
  s.summary          = "A Flutter plugin to retrieve and manage contacts on iOS devices"
  s.description      = <<-DESC
  A Flutter plugin to retrieve and manage contacts on iOS devices.
                       DESC

  s.homepage         = 'https://github.com/ziqq/contactos/contactos_foundation'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = 'Anton Ustinoff'

  # Use local path (plugin shipped from local packages directory for Flutter). Remote :http not needed.
  s.source           = { :path => '.' }
  s.source_files        = 'contactos_foundation/Sources/contactos_foundation/**/*.swift'
  s.requires_arc = true

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  s.ios.frameworks = 'UIKit'
  s.osx.frameworks = 'AppKit'

  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
 }
 s.resource_bundles = {'contactos_privacy' => ['contactos/Sources/contactos/Resources/PrivacyInfo.xcprivacy']}
end

