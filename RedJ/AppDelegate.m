//
//  AppDelegate.m
//  RedJ
//
//  Created by vi~ on 2018/4/13.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "AppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import <UserNotifications/UserNotifications.h>
#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AVOSCloud setApplicationId:@"w2jtKPHTNphHaupsMnTjAuHh-gzGzoHsz" clientKey:@"2U4geIChGWyKrknegJBuYzU8"];
    [AVOSCloud setAllLogsEnabled:YES];
    
    //启动基本SDK
    [[PgyManager sharedPgyManager] startManagerWithAppId:@"d1e93ed372aa6aad95a839658b2bccd9"];
    //启动更新检查SDK
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"d1e93ed372aa6aad95a839658b2bccd9"];

    [[PgyUpdateManager sharedPgyManager] checkUpdate];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"已经可以结算今日注单了" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"快去看看谁今天要发最大的红包吧~" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.hour = 15;
    components.minute = 5;
    components.second = 0;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];

    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"RankingNoti" content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setFadeInAnimationDuration:0];
    [SVProgressHUD setFadeOutAnimationDuration:0];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]] && [AVUser currentUser]) {
        UITabBarController *tabBarVC = (UITabBarController *)self.window.rootViewController;
        if (tabBarVC.childViewControllers.count > 1) {
            tabBarVC.selectedIndex = 1;
        }
    }
    completionHandler();
}



@end
