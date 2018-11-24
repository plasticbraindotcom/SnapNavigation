Pod::Spec.new do |s|

  s.name         = "SnapNavigation"
  s.version      = "1.0.2"
  s.summary      = "Composable view navigation for iOS."

  s.description  = <<-DESC
Comprehensively define and handle all view navigation concerns.
                   DESC

  s.homepage     = "https://github.com/plasticbraindotcom/SnapNavigation"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Stephen Downs" => "steve@plasticbrain.com" }
  s.social_media_url   = "http://twitter.com/plasticbrain"

  s.platform     = :ios, "11.4"

  s.source       = { :git => "https://github.com/plasticbraindotcom/SnapNavigation.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Sources/SnapNavigation/*.{h,m,swift}"

  s.swift_version = '4.2'

end
