//
//  QRCodeReaderView.h
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeReaderView : UIView

/**
 *  @brief  开启扫描动画
 */
- (void)startScanLineAnimation;

/**
 *  @brief  停止扫描动画
 */
- (void)stopScanLineAnimation;

/** 扫描区域位置 */
@property (nonatomic, assign) CGRect   scanRegion;

@end
