//
//  QRCodeReaderViewController.m
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import "QRCodeReaderViewController.h"
#import "QRCodeReaderView.h"
#import "QRCodeReader.h"

@interface QRCodeReaderViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) QRCodeReaderView      *viewReader;
@property (nonatomic, strong) QRCodeReader          *codeReader;
@property (nonatomic, strong) UILabel               *labPrompt;
@property (nonatomic, assign) BOOL                  isViewVisibility;

@property (nonatomic, copy) void (^completionBlock)(NSString *);

@end

@implementation QRCodeReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self isDeviceSupports];
    
    [self setupQRCodeReader];
    
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startScanning];
    self.isViewVisibility = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewVisibility = NO;
    [self stopScanning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.codeReader.videoPreviewLayer.frame = self.view.bounds;
}

- (UILabel *)labPrompt
{
    if (_labPrompt == nil)
    {
        _labPrompt = [[UILabel alloc] init];
        _labPrompt.font = [UIFont systemFontOfSize:15.0f];
        _labPrompt.textColor = [UIColor whiteColor];
        _labPrompt.numberOfLines = 2;
        _labPrompt.textAlignment = NSTextAlignmentCenter;
        _labPrompt.text = @"将二维码放入框内，即可自动扫描";
    }
    return _labPrompt;
}

- (void)setStrPrompt:(NSString *)strPrompt
{
    _strPrompt = strPrompt;
    self.labPrompt.text = strPrompt;
}

#pragma mark - 控制屏幕旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)dealloc
{
    [self removeNotification];
    NSLog(@"%s", __FUNCTION__);
}

- (void)setupQRCodeReader
{
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth  = self.view.frame.size.width;
    
    CGFloat scanWith = screenWidth * 0.75;
    CGRect  rectScan = CGRectMake((screenWidth - scanWith)/2, (screenHeight - scanWith)/2 - 64, scanWith, scanWith);
    self.viewReader = [[QRCodeReaderView alloc] initWithFrame:self.view.frame];
    [self.viewReader setScanRegion:rectScan];
    [self.view addSubview:self.viewReader];
    
    self.labPrompt.frame = CGRectMake(CGRectGetMinX(rectScan), CGRectGetMaxY(rectScan) + 10, CGRectGetWidth(rectScan), 40);
    [self.view addSubview:self.labPrompt];
    
    NSArray *metadata = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    self.codeReader = [[QRCodeReader alloc] initWithMetadataObjectTypes:metadata];
    
    [self.view.layer insertSublayer:self.codeReader.videoPreviewLayer atIndex:0];
    [self.codeReader.videoPreviewLayer setFrame:self.view.frame];
    
    
    CGFloat scanRegionHeight = self.viewReader.scanRegion.size.height;
    CGFloat scanRegionWidth = self.viewReader.scanRegion.size.width;
    
    CGRect  cropRect = CGRectMake((screenWidth - scanRegionWidth) / 2, (screenHeight - scanRegionHeight) / 2, scanRegionWidth, scanRegionHeight);
    
    // 修正扫描区域
    [self.codeReader setScanRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                                      cropRect.origin.x / screenWidth,
                                                      cropRect.size.height / screenHeight,
                                                      cropRect.size.width / screenWidth)];
    __weak typeof(self) weakSelf = self;
    [self.codeReader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"QRCode result: %@", resultAsString);
        if (weakSelf.completionBlock)
        {
            weakSelf.completionBlock(resultAsString);
        }
    }];
}

/**
 *  @brief  判断设备是否支持二维码扫描
 *
 *  @return YES:支持 NO:不支持
 */
- (BOOL)isDeviceSupports
{
    AVAuthorizationStatus authorState = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorState == AVAuthorizationStatusRestricted || authorState == AVAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在iPhone的\"设置-隐私-相机\"选项中,允许访问您的相机" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alert show];
        return NO;
    }
    
    if ([QRCodeReader isAvailable] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备相机不支持二维码扫描" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alert show];
        return NO;
    }
    return YES;
}

+ (BOOL)isDeviceSupports
{
    AVAuthorizationStatus authorState = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorState == AVAuthorizationStatusRestricted || authorState == AVAuthorizationStatusDenied)
    {
        return NO;
    }
    
    if ([QRCodeReader isAvailable] == NO)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - 注册APP全局通知
- (void)addNotification
{
    // 进入后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    // 进入前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

// 处理进入后台通知
- (void)handleDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self stopScanning];
}

// 处理进入前台通知
- (void)handleWillEnterForegroundNotification:(NSNotification *)notification
{
    if (self.isViewVisibility)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startScanning];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setter & Getter
- (void)setCompletionWithBlock:(void (^)(NSString *))completionBlock
{
    self.completionBlock = completionBlock;
}

- (void)startScanning
{
    [self.codeReader startRunning];
    [self.viewReader startScanLineAnimation];
}

- (void)stopScanning
{
    [self.codeReader stopRunning];
    [self.viewReader stopScanLineAnimation];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.presentingViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
