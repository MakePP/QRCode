//
//  ViewController.m
//  QRCode
//
//  Created by 彭鹏 on 16/6/11.
//  Copyright © 2016年 MakePP. All rights reserved.
//


#import "QRCodeReaderViewController.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionScanQRCode:(id)sender
{
    QRCodeReaderViewController *qrcodeVC = [[QRCodeReaderViewController alloc] init];
    qrcodeVC.title = @"Demo";
    [self.navigationController pushViewController:qrcodeVC animated:YES];
    
    [qrcodeVC setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"%@", resultAsString);
    }];
}

- (IBAction)actionGeneQRCode:(id)sender {
    
}

- (IBAction)acitonGeneBarCode:(id)sender {
    
}
@end
