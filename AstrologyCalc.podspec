Pod::Spec.new do |s|
    
    # 1
    s.platform = :ios
    s.ios.deployment_target = '10.0'
    s.name = "AstrologyCalc"
    s.summary = "AstrologyCalc swift 4.2 framework for simple development amazing apps."
    s.requires_arc = true
    # s.swift_version = '4.2'
    
    # 2
    s.version = "0.0.4"
    
    # 3
    s.license = { :type => "MIT", :file => "LICENSE" }
    
    # 4 - Replace with your name and e-mail address
    s.author = { "Emil Karimov" => "emvakar@gmail.com" }
    
    # 5 - Replace this URL with your own Github page's URL (from the address bar)
    s.homepage = "https://github.com/emvakar/AstrologyCalc.git"
    s.social_media_url = 'https://twitter.com/e_karimov'
    
    # 6 - Replace this URL with your own Git URL from "Quick Setup"
    s.source = { :git => "https://github.com/emvakar/AstrologyCalc.git", :tag => "v" + s.version.to_s }
    
    # 7
    s.framework = "UIKit"
    s.framework = "Foundation"
    s.framework = "CoreLocation"
    
    s.dependency 'DevHelper'

    # 8
    s.source_files = "AstrologyCalc/**/*.{swift}"
    
    # 9
#     s.resources = "AstrologyCalc/*.{png,jpeg,jpg,storyboard,xib,json}"
     s.resources = ['parsing.json', 'AstrologyCalc/DataBase/cities_coordinates.json', 'AstrologyCalc/DataBase/jsons/db_0.json', 'AstrologyCalc/DataBase/jsons/db_1.json', 'AstrologyCalc/DataBase/jsons/db_2.json', 'AstrologyCalc/DataBase/jsons/db_3.json', 'AstrologyCalc/DataBase/jsons/db_4.json', 'AstrologyCalc/DataBase/jsons/db_5.json', 'AstrologyCalc/DataBase/jsons/db_6.json', 'AstrologyCalc/DataBase/jsons/db_7.json', 'AstrologyCalc/DataBase/jsons/db_8.json', 'AstrologyCalc/DataBase/jsons/db_9.json', 'AstrologyCalc/DataBase/jsons/db_10.json', 'AstrologyCalc/DataBase/jsons/db_11.json', 'AstrologyCalc/DataBase/jsons/db_12.json', 'AstrologyCalc/DataBase/jsons/db_13.json', 'AstrologyCalc/DataBase/jsons/db_14.json', 'AstrologyCalc/DataBase/jsons/db_15.json', 'AstrologyCalc/DataBase/jsons/db_16.json', 'AstrologyCalc/DataBase/jsons/db_17.json', 'AstrologyCalc/DataBase/jsons/db_18.json', 'AstrologyCalc/DataBase/jsons/db_19.json', 'AstrologyCalc/DataBase/jsons/db_20.json', 'AstrologyCalc/DataBase/jsons/db_21.json', 'AstrologyCalc/DataBase/jsons/db_22.json', 'AstrologyCalc/DataBase/jsons/db_23.json', 'AstrologyCalc/DataBase/jsons/db_24.json', 'AstrologyCalc/DataBase/jsons/db_25.json', 'AstrologyCalc/DataBase/jsons/db_26.json', 'AstrologyCalc/DataBase/jsons/db_27.json', 'AstrologyCalc/DataBase/jsons/db_28.json', 'AstrologyCalc/DataBase/jsons/db_29.json', 'AstrologyCalc/DataBase/jsons/db_30.json', 'AstrologyCalc/DataBase/jsons/db_31.json', 'AstrologyCalc/DataBase/jsons/db_32.json', 'AstrologyCalc/DataBase/jsons/db_33.json', 'AstrologyCalc/DataBase/jsons/db_34.json', 'AstrologyCalc/DataBase/jsons/db_35.json', 'AstrologyCalc/DataBase/jsons/db_36.json', 'AstrologyCalc/DataBase/jsons/db_37.json', 'AstrologyCalc/DataBase/jsons/db_38.json', 'AstrologyCalc/DataBase/jsons/db_39.json', 'AstrologyCalc/DataBase/jsons/db_40.json', 'AstrologyCalc/DataBase/jsons/db_41.json', 'AstrologyCalc/DataBase/jsons/db_42.json', 'AstrologyCalc/DataBase/jsons/db_43.json', 'AstrologyCalc/DataBase/jsons/db_44.json', 'AstrologyCalc/DataBase/jsons/db_45.json', 'AstrologyCalc/DataBase/jsons/db_46.json', 'AstrologyCalc/DataBase/jsons/db_47.json', 'AstrologyCalc/DataBase/jsons/db_48.json', 'AstrologyCalc/DataBase/jsons/db_49.json', 'AstrologyCalc/DataBase/jsons/db_50.json', 'AstrologyCalc/DataBase/jsons/db_51.json', 'AstrologyCalc/DataBase/jsons/db_52.json', 'AstrologyCalc/DataBase/jsons/db_53.json', 'AstrologyCalc/DataBase/jsons/db_54.json', 'AstrologyCalc/DataBase/jsons/db_55.json', 'AstrologyCalc/DataBase/jsons/db_56.json', 'AstrologyCalc/DataBase/jsons/db_57.json', 'AstrologyCalc/DataBase/jsons/db_58.json', 'AstrologyCalc/DataBase/jsons/db_59.json', 'AstrologyCalc/DataBase/jsons/db_60.json', 'AstrologyCalc/DataBase/jsons/db_61.json', 'AstrologyCalc/DataBase/jsons/db_62.json', 'AstrologyCalc/DataBase/jsons/db_63.json', 'AstrologyCalc/DataBase/jsons/db_64.json', 'AstrologyCalc/DataBase/jsons/db_65.json', 'AstrologyCalc/DataBase/jsons/db_66.json', 'AstrologyCalc/DataBase/jsons/db_67.json']
     s.resource_bundles = {
        'AstrologyCalcAssets' => ['AstrologyCalc/**/*.xcassets']
     }
end
