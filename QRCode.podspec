#
#  Be sure to run `pod spec lint QRCode.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

# Pod::Spec.new do |s|
#   s.name         = "QRCode" # 项目名称
#   s.version      = "1.0.0"        # 版本号 与 你仓库的 标签号 对应
#   s.license      = "MIT"          # 开源证书
#   s.summary      = "提供iOS平台下，基于系统API封装二维码扫描功能" # 项目简介

#   s.homepage     = "https://github.com/MakePP/QRCode" # 你的主页
#   s.source       = { :git => "https://github.com/MakePP/QRCode.git", :tag => "#{s.version}" }#你的仓库地址，不能用SSH地址
#   s.source_files = "QRCode/QRCodeReader/*.{h,m}" # 你代码的位置， BYPhoneNumTF/*.{h,m} 表示 BYPhoneNumTF 文件夹下所有的.h和.m文件
#   s.requires_arc = true # 是否启用ARC
#   s.platform     = :ios, "7.0" #平台及支持的最低版本
#   s.frameworks   = "UIKit", "Foundation" #支持的框架
#   # s.dependency = "AFNetworking" # 依赖库
  
#   # User
#   s.author             = { "BY" => "peng163199184@163.com" } # 作者信息
#   s.social_media_url   = "https://github.com/MakePP" # 个人主页

# end

Pod::Spec.new do |s|
  s.name         = "QRCode"
  s.version      = "1.0.0"
  s.summary      = "提供iOS平台下，基于系统API封装二维码扫描功能"

  s.homepage     = "https://github.com/MakePP/QRCode"
  
  s.license      = 'MIT'
  s.author       = { "BY" => "peng163199184@163.com" }
  s.social_media_url = "https://github.com/MakePP"
  s.source       = { :git => "https://github.com/MakePP/QRCode.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'QRCode/QRCodeReader/*.{h,m}'
  s.frameworks = 'Foundation', 'UIKit'
  #s.private_header_files = 'Classes/ios/private/*.h'
  
  #s.dependency 'FLKAutoLayout', '~> 0.1'
end