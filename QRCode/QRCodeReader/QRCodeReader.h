//
//  QRCodeReader.h
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface QRCodeReader : NSObject

@property (strong, nonatomic, readonly) NSArray *metadataObjectTypes;

@property (strong, nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

#pragma mark - Creating and Inializing QRCode Readers

/**
 *  @brief  初始化一个带有元数据类型的QRCodeReader对象
 *
 *  @param  metadataObjectTypes 元数据类型数组
 *
 *  @return QRCodeReader对象
 */
- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes;

/**
 *  @brief  通过类方法创建一个带有元数据类型的QRCodeReader对象
 *
 *  @param  metadataObjectTypes 元数据类型数组
 *
 *  @return QRCodeReader对象
 */
+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes;

#pragma mark - Checking the Reader Availabilities

/**
 *  @brief   检测当前设备是否支持扫描
 *
 *  @return  YES:支持 NO:不支持
 */
+ (BOOL)isAvailable;

/**
 *  @brief  返回视频支持的方向
 *
 *  @param  interfaceOrientation 设备方向
 *
 *  @return 返回需要视频支持的方向值
 */
+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 *  @brief 修正扫描区域位置
 *
 *  @param rect 扫描区域位置
 */
- (void)setScanRectOfInterest:(CGRect)rect;

/**
 *  @brief  检测当前设备是否支持元数据类型
 *
 *  @param  metadataObjectTypes 元数据类型数组
 *
 *  @return YES:支持 NO:不支持
 */
//+ (BOOL)supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes;

#pragma mark - Controlling the Reader
/**
 *  @brief  开始扫描
 */
- (void)startRunning;

/**
 *  @brief  停止扫描
 */
- (void)stopRunning;

/**
 *  @brief  当前设备是否正在扫描
 */
- (BOOL)running;

#pragma mark - Managing the Block
/**
 *  @brief 设置执行扫描完成或者停止扫描时回调的block
 *
 *  @param completionBlock 扫描完成回调的block, 扫描成功resultAsString参数返回字符串，停止或失败则返回nil
 */
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock;

@end
