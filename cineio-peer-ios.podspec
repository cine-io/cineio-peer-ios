Pod::Spec.new do |s|
  s.name                = "cineio-peer-ios"
  s.version             = "0.0.1"
  s.summary             = "cine.io Peer iOS SDK"
  s.description      = <<-DESC
                          iOS SDK for Peer to Peer using the cine.io API.
                          DESC
  s.homepage            = "https://github.com/cine-io/cineio-peer-ios"
  s.license             = 'MIT'
  s.authors             = { "Cine.io Team" => "support@cine.io" }
  s.source              = { :git => "https://github.com/cine-io/cineio-peer-ios.git", :tag => s.version.to_s }

  s.requires_arc        = true

  s.header_dir          = 'cineio'

  s.source_files        = [ 'cineio-peer-ios/cineio-peer-ios/*.h',
                            'cineio-peer-ios/cineio-peer-ios/*.m*',
                            'cineio-peer-ios/cineio-peer-ios/*.c*' ]

  s.frameworks          = [ 'Foundation', 'UIKit', 'AVFoundation', 'GLKit' ]

  s.dependency          'libjingle_peerconnection', '~> 8515.2.0'
  s.dependency          'Primus'#, '~> 0.2.1.2' # use our version till https://github.com/seegno/primus-objc/pull/12 is merged in
  s.dependency          'SocketRocket', '~> 0.3.1-beta2'

  s.ios.deployment_target = '8.1'
end
