//
//  ViewController.m
//  ScanCardGetInfo
//
//  Created by 毛韶谦 on 16/6/22.
//  Copyright © 2016年 毛韶谦. All rights reserved.
//

#import "ViewController.h"
#import "MSQScanCardViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
