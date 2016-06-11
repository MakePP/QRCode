//
//  QRCodeGenerator.m
//  Food
//
//  Created by pengpeng on 16/3/1.
//  Copyright © 2016年 MakePP. All rights reserved.
//

#import "QRCodeGenerator.h"

@implementation QRCodeGenerator

#pragma mark - 生成二维码

+ (void)createQRCodeWithContent:(NSString *)content completion:(void (^)(UIImage *))completion
{
    [self createQRCodeWithContent:content centreAvatar:nil avatarScale:0 completion:completion];
}

+ (void)createQRCodeWithContent:(NSString *)content
                   centreAvatar:(UIImage *)avatar
                    avatarScale:(CGFloat)scale
                     completion:(void (^)(UIImage *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        UIImage *qrImage = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            // 仅支持iOS8及以上系统使用
            CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
            
            NSData *dataContent = [content dataUsingEncoding:NSUTF8StringEncoding];
            [qrFilter setDefaults];
            [qrFilter setValue:dataContent forKey:@"inputMessage"];
            
            CIImage *ciImage = qrFilter.outputImage;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(10, 10);
            CIImage *transformedImage = [ciImage imageByApplyingTransform:transform];
            
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgImage = [context createCGImage:transformedImage fromRect:transformedImage.extent];
            qrImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CGImageRelease(cgImage);
        }
        else
        {
            qrImage = [self generatorCodeWithContent:content imageSize:CGSizeMake(300, 300)];
        }
        
        if (avatar != nil) {
            qrImage = [self qrcodeImage:qrImage addAvatar:avatar scale:scale];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(qrImage);
        });
    });
}

+ (UIImage *)qrcodeImage:(UIImage *)qrImage addAvatar:(UIImage *)avatar scale:(CGFloat)scale
{
    scale = (scale < 0) ? 0 : scale;
    scale = (scale > 1) ? 1 : scale;
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect rect = CGRectMake(0, 0, qrImage.size.width * screenScale, qrImage.size.height * screenScale);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, screenScale);
    
    [qrImage drawInRect:rect];
    
    CGSize avatarSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
    CGFloat x = (rect.size.width - avatarSize.width) * 0.5;
    CGFloat y = (rect.size.height - avatarSize.height) * 0.5;
    [avatar drawInRect:CGRectMake(x, y, avatarSize.width, avatarSize.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:result.CGImage scale:screenScale orientation:UIImageOrientationUp];
}

+ (UIImage *)generatorCodeWithContent:(NSString *)content imageSize:(CGSize)size
{
    // 创建Filter
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 通过KVO设置属性值
    NSData  *dataContent = [content dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:dataContent forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // 输出图片
    CIImage *qrCodeImage = [filter outputImage];
    CGRect extent = CGRectIntegral(qrCodeImage.extent);
    
    // 调整二维码大小
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    size_t width  = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:qrCodeImage fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *imgResult = [UIImage imageWithCGImage:scaledImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return imgResult;
}

@end
