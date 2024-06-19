# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

#source 'https://github.com/CocoaPods/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'Saw Grow' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Saw Grow
  
pod 'Alamofire', '~> 5.4'
pod 'SwiftyJSON'
pod 'SDWebImage'
pod 'ProgressHUD'
pod 'IQKeyboardManagerSwift'
pod 'SideMenuSwift'
pod 'OverlayContainer'
pod 'GoogleMaps'#, '~> 5.2.0'
pod 'FSCalendar'
pod 'Localize-Swift', '~> 3.2'
pod 'LineSDKSwift'
pod 'MTSlideToOpen'
#pod 'Firebase/Analytics'
#pod 'Firebase/Messaging'
#pod 'Firebase/Crashlytics'

#pod 'SideMenu'
#pod 'SnapKit', '~> 5.0.0'
#pod 'Kingfisher', '~> 7.0'
#pod 'RxSwift', '6.2.0'
#pod 'RxCocoa', '6.2.0'
#pod 'RealmSwift', '~>10'
#pod 'ObjectMapper', '~> 3.5'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    shell_script_path = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"
    if File::exists?(shell_script_path)
      shell_script_input_lines = File.readlines(shell_script_path)
      shell_script_output_lines = shell_script_input_lines.map { |line| line.sub("source=\"$(readlink \"${source}\")\"", "source=\"$(readlink -f \"${source}\")\"") }
      File.open(shell_script_path, 'w') do |f|
        shell_script_output_lines.each do |line|
          f.write line
        end
      end
    end
    # Fix libarclite_xxx.a file not found.
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

end
