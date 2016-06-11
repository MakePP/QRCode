//
//  QRCodeReader.m
//
//  Created by pengpeng on 15/9/23.
//  Copyright (c) 2015年 MakePP. All rights reserved.
//

#import "QRCodeReader.h"

@interface QRCodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession              *captureSession;
@property (nonatomic, strong) AVCaptureDevice               *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput          *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput       *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *videoPreviewLayer;

@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation QRCodeReader

#pragma mark - Create & Init
- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    self = [super init];
    if (self)
    {
        _metadataObjectTypes = metadataObjectTypes;
        
        [self setupAVComponents];
    }
    
    return self;
}

+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

- (void)setupAVComponents
{
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.captureDevice)
    {
        self.deviceInput       = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
        self.metadataOutput    = [[AVCaptureMetadataOutput alloc] init];
        self.captureSession    = [[AVCaptureSession alloc] init];
        self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        
        // 添加输入输出到Session中
        if (self.deviceInput)
        {
            [self.captureSession addInput:self.deviceInput];
            [self.captureSession addOutput:self.metadataOutput];
        }
        
        if ([QRCodeReader supportsMetadataObjectTypes:self.metadataObjectTypes])
        {
            [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [self.metadataOutput setMetadataObjectTypes:self.metadataObjectTypes];
            [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
            [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
        
        [self.captureSession beginConfiguration];
        BOOL result = [self.captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080];
        if (result)
        {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
        else
        {
            [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        [self.captureSession commitConfiguration];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *currentMetadata in metadataObjects)
    {
        if ([currentMetadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]] &&
            [self.metadataObjectTypes containsObject:currentMetadata.type])
        {
            AVMetadataMachineReadableCodeObject *metadataMachineReadableCode = (AVMetadataMachineReadableCodeObject *)currentMetadata;
            NSString *resultScan = metadataMachineReadableCode.stringValue;
            if (self.completionBlock)
            {
                self.completionBlock(resultScan);
            }
            break;
        }
    }
}

#pragma mark - Managing the Block
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Controlling the Reader
- (void)startRunning
{
    if ([self.captureSession isRunning] == NO)
    {
        [self.captureSession startRunning];
    }
}

- (void)stopRunning
{
    if ([self.captureSession isRunning])
    {
        [self.captureSession stopRunning];
    }
}

- (BOOL)running
{
    return [self.captureSession isRunning];
}

#pragma mark - Checking the Reader Availabilities

+ (BOOL)isAvailable
{
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        return YES;
    }
}

+ (BOOL)supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    if (![self isAvailable])
    {
        return NO;
    }
    
    @autoreleasepool {
        // Setup components
        AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
        AVCaptureSession *session         = [[AVCaptureSession alloc] init];
        
        [session addInput:deviceInput];
        [session addOutput:output];
        
        if (metadataObjectTypes == nil || metadataObjectTypes.count == 0)
        {
            // Check the QRCode metadata object type by default
            metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        }
        
        for (NSString *metadataObjectType in metadataObjectTypes)
        {
            if (![output.availableMetadataObjectTypes containsObject:metadataObjectType]) {
                return NO;
            }
        }
        
        return YES;
    }
}

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        default:
            return AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

- (void)setScanRectOfInterest:(CGRect)rect
{
    [self.metadataOutput setRectOfInterest:rect];
}
@end
