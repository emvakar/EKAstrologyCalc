Pod::Spec.new do |s|
    
    # 1
    s.platform = :ios
    s.ios.deployment_target = '10.0'
    s.name = "AstrologyCalc"
    s.summary = "AstrologyCalc swift 4.2 framework for simple development amazing apps."
    s.requires_arc = true
    
    # 2
    s.version = "0.0.1"
    
    # 3
    s.license = { :type => "MIT", :file => "LICENSE" }
    
    # 4 - Replace with your name and e-mail address
    s.author = { "Emil Karimov" => "emvakar@gmail.com" }
    
    # 5 - Replace this URL with your own Github page's URL (from the address bar)
    s.homepage = "https://github.com/emvakar/AstrologyCalc.git"
    
    # 6 - Replace this URL with your own Git URL from "Quick Setup"
    s.source = { :git => "https://github.com/emvakar/AstrologyCalc.git", :tag => "#{s.version}"}
    
    # 7
    s.framework = "UIKit"
    s.framework = "Foundation"
    s.framework = "CoreLocation"
    
    # 8
    s.source_files = "Astrology Calculator/**/**/*.{swift}"
    
    # 9
    s.resources = "Astrology Calculator/**/*.{png,jpeg,jpg,storyboard,xib}"
    s.resource_bundles = {
        'AstrologyCalcAssets' => ['AstrologyCalc/**/*.xcassets']
    }
end
