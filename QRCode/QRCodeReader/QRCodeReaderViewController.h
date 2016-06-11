//
//  QRCodeReaderViewController.h
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeReaderViewController : UIViewController

/**
 *  二维码扫描提示字符串
 */
@property (nonatomic, strong) NSString  *strPrompt;

/**
 *  @brief 扫描完成回调block
 */
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock;

/**
 *  @brief  开始扫描
 */
- (void)startScanning;

/**
 *  @brief  停止扫描
 */
- (void)stopScanning;

/**
 *  @brief  判断设备是否支持二维码扫描
 *
 *  @return YES:支持 NO:不支持
 */
+ (BOOL)isDeviceSupports;

@end
