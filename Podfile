platform :ios, '10.0'

def calcPods
  pod 'DevHelper', :git => 'https://github.com/emvakar/DevHelper.git', :branch => 'master', :modular_headers => true
  end

target 'AstrologyCalc' do
  use_frameworks!
  calcPods
end

target 'AstrologyCalcTests' do
  use_frameworks!
  calcPods
end

target 'Example App' do
  use_frameworks!
  calcPods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      #config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      #config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      #config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '3'
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
