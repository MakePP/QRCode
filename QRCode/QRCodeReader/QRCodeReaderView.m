//
//  QRCodeReaderView.m
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import "QRCodeReaderView.h"

static NSTimeInterval kScanLineAnimateDuration = 1.5f;

@interface QRCodeReaderView ()
{
    BOOL            _isAnimating;
    //CGRect          _rectScan;      // 扫描区域
    CGFloat         _lineWidth;     // 扫描边框线的宽度
    UIImageView     *_imgvLine;     // 扫描动画图片
}
@end

@implementation QRCodeReaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self.scanRegion = CGRectMake((CGRectGetWidth(frame) - 250)/2, (CGRectGetHeight(frame) - 250)/2, 250, 250);
        _lineWidth = 0.8f;
        
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    if (_imgvLine == nil)
    {
        _imgvLine = [[UIImageView alloc] init];
        _imgvLine.image = [UIImage imageNamed:@"qrcode_line"];
        
        CGRect frame = self.scanRegion;
        frame.size.height = 0;
        _imgvLine.frame = frame;
        
        [self addSubview:_imgvLine];
    }
}

- (void)setScanRegion:(CGRect)scanRegion
{
    _scanRegion = scanRegion;
    
    CGRect frame = scanRegion;
    frame.size.height = 0;
    _imgvLine.frame = frame;
}

// Only override drawRect, perform custom drawing.
- (void)drawRect:(CGRect)rect
{
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    [self drawOverlayRect:contex];
    
    [self drawScanRect:contex];
    
    [self drawScanCornerLine:contex];
}

// 画全屏虚化背景
- (void)drawOverlayRect:(CGContextRef)contex
{
    CGContextSetRGBFillColor(contex, 40 / 255.0, 40 / 255.0, 40 / 255.0, 0.5);
    CGContextFillRect(contex, self.frame);
}

// 画扫描区域矩形框
- (void)drawScanRect:(CGContextRef)contex
{
    CGContextClearRect(contex, self.scanRegion);
    
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(contex, _lineWidth);
    CGContextAddRect(contex, self.scanRegion);
    CGContextStrokePath(contex);
}

/**
 *  @brief  画扫描区域线条
 */
- (void)drawScanCornerLine:(CGContextRef)contex
{
    // 扫描区域的x, y, w, h
    CGFloat x = self.scanRegion.origin.x;
    CGFloat y = self.scanRegion.origin.y;
    CGFloat w = self.scanRegion.size.width;
    CGFloat h = self.scanRegion.size.height;
    
    CGFloat lineLength = 15.f;
    CGFloat lineWidth  = 2.0f;
    CGFloat offset     = lineWidth/3;
    
    [[UIColor colorWithRed:0.078 green:0.596 blue:0.914 alpha:1.000] setStroke];
    CGContextSetLineWidth(contex, lineWidth);
    CGContextSetLineCap(contex, kCGLineCapButt);
    
    CGContextBeginPath(contex);
    
    // 左上角直角线的坐标
    CGPoint pointTopLeft[] = { CGPointMake(x + offset, y + offset + lineLength), CGPointMake(x + offset, y + offset), CGPointMake(x + offset + lineLength, y + offset) };
    CGContextAddLines(contex, pointTopLeft, 3);
    
    // 左下角直角线的坐标
    CGPoint pointBottomLeft[] = { CGPointMake(x + offset, y + h - offset - lineLength), CGPointMake(x + offset, y + h - offset), CGPointMake(x + offset + lineLength, y + h - offset) };
    CGContextAddLines(contex, pointBottomLeft, 3);
    
    // 右上角直角线的坐标
    CGPoint pointTopRight[] = { CGPointMake(x + w - lineLength - offset, y + offset), CGPointMake(x + w - offset, y + offset), CGPointMake(x + w - offset, y + offset + lineLength) };
    CGContextAddLines(contex, pointTopRight, 3);
    
    // 右下角直角线的坐标
    CGPoint pointBottomRight[] = { CGPointMake(x + w - offset, y + h - offset - lineLength), CGPointMake(x + w - offset, y + h - offset), CGPointMake(x + w - lineLength - offset, y + h - offset) };
    CGContextAddLines(contex, pointBottomRight, 3);
    
    CGContextStrokePath(contex);
}

#pragma mark - Scan Animation
- (void)startScanLineAnimation
{
    if (_isAnimating)
    {
        return;
    }
    
    _isAnimating = YES;
    _imgvLine.hidden = NO;
    [self scanLine];
}

- (void)stopScanLineAnimation
{
    _imgvLine.hidden = YES;
    _isAnimating = NO;
    [_imgvLine.layer removeAllAnimations];
}

- (void)scanLine
{
    [UIView animateWithDuration:kScanLineAnimateDuration delay:0 options:UIViewAnimationOptionRepeat animations:^{
        
        CGRect frame = _imgvLine.frame;
        frame.size.height = self.scanRegion.size.height;
        _imgvLine.frame = frame;
        
    } completion:^(BOOL finished) {
        CGRect frame = _imgvLine.frame;
        frame.size.height = 0;
        _imgvLine.frame = frame;
    }];
}
@end
