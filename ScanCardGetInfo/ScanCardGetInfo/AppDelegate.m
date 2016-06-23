//
//  AppDelegate.m
//  ScanCardGetInfo
//
//  Created by 毛韶谦 on 16/6/22.
//  Copyright © 2016年 毛韶谦. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self creatShortcutItem];
    
    UIApplicationShortcutItem *shortcutItem = [launchOptions valueForKey:UIApplicationLaunchOptionsShortcutItemKey];
    
    if (shortcutItem) {  //从快捷键进入系统，
        
        if ([shortcutItem.type isEqualToString:@"scanCard"]) {
            
            //扫一扫 快捷键进入
            self.intoScanCard = @"scanCard";
        }
    }
    return YES;
}

//创建3D touch应用图标上的
- (void)creatShortcutItem {
    
    //创建系统风格icon
//    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove];
    
    //创建自定义的icon 图标
    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"Unknown.png"];
    //创建快捷选项
    UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:@"scanCard" localizedTitle:@"扫一扫" localizedSubtitle:nil icon:icon userInfo:nil];
    //添加到快捷选项中
    [UIApplication sharedApplication].shortcutItems = @[item];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
