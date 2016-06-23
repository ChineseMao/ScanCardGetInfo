//
//  ViewController.m
//  ScanCardGetInfo
//
//  Created by 毛韶谦 on 16/6/22.
//  Copyright © 2016年 毛韶谦. All rights reserved.
//

#import "ViewController.h"
#import "MSQScanCardViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIApplicationShortcutIconTypeAdd
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate.intoScanCard isEqualToString:@"scanCard"]) {
        
        [self performSelector:@selector(openScanCardVC:) withObject:nil afterDelay:1];
        appDelegate.intoScanCard = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openScanCardVC:(UIButton *)sender {
    
    MSQScanCardViewController *scanCardVC = [[MSQScanCardViewController alloc] init];
    
    [self.navigationController pushViewController:scanCardVC animated:YES];
}

@end
