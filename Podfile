platform :ios, '10.0'

def calcPods
  pod 'DevHelper', :git => 'https://github.com/emvakar/DevHelper.git', :branch => 'master', :modular_headers => true
  end

target 'AstrologyCalc' do
  use_frameworks!
  calcPods
  
  target 'AstrologyCalcTests' do
    inherit! :search_paths
    calcPods
  end

end

target 'Example App' do
  use_frameworks!
  calcPods

end
