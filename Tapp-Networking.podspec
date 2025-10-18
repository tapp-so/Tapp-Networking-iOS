Pod::Spec.new do |spec|
  spec.name          = 'Tapp-Networking'
  spec.version       = '1.0.87'
  spec.license       = { :type => 'BSD' }
  spec.homepage      = 'https://github.com/tapp-so/Tapp-Networking-iOS'
  spec.authors       = { 'Alex Stergiou' => 'alex.stergiou@hotmail.com' }
  spec.summary       = 'TappSDK.'
  spec.source        = { :git => 'https://github.com/tapp-so/Tapp-Networking-iOS.git', :tag => '1.0.87' }
  spec.module_name   = 'TappNetworking'
  spec.swift_version = '5.7'
  spec.license       = { :type => 'MIT', :file => 'LICENSE.md' }

  spec.ios.deployment_target  = '13.0'

  spec.source_files       = 'Sources/**/*.swift'
  spec.ios.source_files   = 'Sources/**/*.swift'

  spec.framework      = 'SystemConfiguration'
  spec.ios.framework  = 'Foundation'
end
