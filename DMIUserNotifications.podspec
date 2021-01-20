
Pod::Spec.new do |s|

  s.name         = "DMIUserNotifications"
  s.version      = "0.0.1"
  s.summary      = "Local Notification Helper for User Notifications framework"

 
  s.description  = <<-DESC
		   "DMIUserNotifications makes it extremely easy to setup a local 	notification, while making it easy to repeat notifications, and encapsulating away the intricacies of the User Notifications Framework."
                   DESC

  s.homepage     = "https://github.com/KamleshHBTI/DMIUserNotifications.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author    = "Kamlesh Kumar"
  


  s.platform     = :ios
  s.source       = { :git => "https://github.com/KamleshHBTI/DMIUserNotifications.git", :tag => s.version}

  s.source_files = "DMIUserNotifications", "DMIUserNotifications/**/*.{h,m,swift}"
  s.requires_arc            = true
  s.ios.deployment_target   = '11.0'
  s.swift_version           = '5.0'

end
