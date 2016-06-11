//
//  QRCodeGenerator.h
//  Food
//
//  Created by pengpeng on 16/3/1.
//  Copyright © 2016年 MakePP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeGenerator : NSObject

/**
 *  生成二维码图片
 *
 *  @param content    二维码内容
 *  @param completion 生成二维码完成后调用
 */
+ (void)createQRCodeWithContent:(NSString *)content
                     completion:(void (^)(UIImage *image))completion;

/**
 *  生成【二维码+自定义图片】类型的二维码
 *
 *  @param content    二维码内容
 *  @param avatar     中间自定义图片
 *  @param scale      自定义图片比例(0-1之间)
 *  @param completion 生成二维码完成后调用
 */
+ (void)createQRCodeWithContent:(NSString *)content
                   centreAvatar:(UIImage *)avatar
                    avatarScale:(CGFloat)scale
                     completion:(void (^)(UIImage *image))completion;
@end
