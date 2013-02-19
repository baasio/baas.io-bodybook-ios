//
//  AppDelegate.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 4..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import <baas.io/Baas.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Baasio setApplicationInfo:@"ceffba5f-3514-11e2-a2c1-02003a570010" applicationName:@"d31a99ec-3514-11e2-a2c1-02003a570010"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSDictionary *dictionary = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSDictionary *aps = [dictionary objectForKey:@"aps"];
	application.applicationIconBadgeNumber = [[aps objectForKey:@"badge"] intValue];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Apple Push Notifications
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// didFinishLaunchingWithOptions를 구현할 경우 사용되지 않는다.
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

// 애플리케이션 실행 중에 RemoteNotification 을 수신
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //	NSLog(@"1. didReceiveRemoteNotification");
	// push 메시지 추출
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
	application.applicationIconBadgeNumber = [[aps objectForKey:@"badge"] intValue];
	
    // alert 추출
//    NSString *alertMessage = [aps objectForKey:@"alert"];
//	
//	NSString *string = [NSString stringWithFormat:@"%@", alertMessage];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                    message:string delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//	[alert show];
}

// RemoteNotification 등록 성공. deviceToken을 수신
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"2. didRegisterForRemoteNotificationsWithDeviceToken");
	
	NSMutableString *deviceId = [NSMutableString string];
	const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
	
	for(int i = 0 ; i < 32 ; i++)
	{
		[deviceId appendFormat:@"%02x", ptr[i]];
	}
    NSLog(@"디바이스 아이디 : %@", deviceId);
    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"deviceID"]){
        NSLog(@"저장되어있지않음");
        BaasioPush *push = [[BaasioPush alloc] init];
        NSArray *tags = @[[NSString stringWithFormat:@"t%@",[[BaasioUser currentUser] objectForKey:@"username"]]];
        NSString *deviceIDString = [NSString stringWithFormat:@"%@",deviceId];
        [push registerInBackground:deviceIDString
                              tags:(NSArray *)tags
                      successBlock:^(void) {
                          NSLog(@"baas.io에 device가 등록됨");
                          [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"deviceID"];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                      }
                      failureBlock:^(NSError *error) {
                          NSLog(@"device등록 실패 : %@", error.localizedDescription);
                      }];
    }
}

// APNS 에 RemoteNotification 등록 실패
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	NSLog(@"Error in registration. Error: %@", error);
}


@end
