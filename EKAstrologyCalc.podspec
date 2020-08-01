Pod::Spec.new do |s|
    
    s.platform = :ios
    s.ios.deployment_target = '11.0'
    s.name = "EKAstrologyCalc"
    s.summary = "EKAstrologyCalc swift 5.2 framework for simple development amazing apps."
    s.requires_arc = true
    s.swift_version = '5.2'
    s.version = "1.0.3"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "Emil Karimov" => "emvakar@gmail.com" }
    s.homepage = "https://github.com/emvakar/EKAstrologyCalc.git"
    s.social_media_url = 'https://www.facebook.com/emvakar'
    s.source = { :git => "https://github.com/emvakar/EKAstrologyCalc.git", :tag => "v" + s.version.to_s }
    
    s.framework = "Foundation"
    s.framework = "CoreLocation"
    
    s.dependency 'ESDateHelper'
    s.source_files = "AstrologyCalc/Moon/**/*.{swift}"
end
