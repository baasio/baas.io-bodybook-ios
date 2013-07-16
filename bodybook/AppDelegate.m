//
//  AppDelegate.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 4..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "SHSidebarController.h"
#import "UserViewController.h"
#import "NewsFeedController.h"
//#import "AddFriendViewController.h"
#import "AddFriendController.h"

#import <baas.io/Baas.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Baasio setApplicationInfo:@"ceffba5f-3514-11e2-a2c1-02003a570010" applicationName:@"d31a99ec-3514-11e2-a2c1-02003a570010"];
    [[Baasio sharedInstance]isDebugMode:YES];
//    [Baasio setApplicationInfo:@"https://stgapi.baas.io/" baasioID:@"d485c0b8-b2e0-11e2-9392-02004d450054" applicationName:@"de0257ae-b2e0-11e2-9392-02004d450054"];
    
//    [Baasio setApplicationInfo:@"https://devapi.baas.io/" baasioID:@"7fd4547c-b2c1-11e2-b08a-02004d17003f" applicationName:@"80094718-b2c1-11e2-b08a-02004d17003f"];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    //BaasioUser *currentUser = [BaasioUser currentUser];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userID"] == nil) {
        self.window.rootViewController = self.viewController;
    }else{
        [self login];
    }
    [self.window makeKeyAndVisible];

    NSDictionary *dictionary = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSDictionary *aps = [dictionary objectForKey:@"aps"];
	application.applicationIconBadgeNumber = [[aps objectForKey:@"badge"] intValue];
    
    return YES;
}

- (void)login{
    NSError *error;
    [BaasioUser signIn:[[NSUserDefaults standardUserDefaults] stringForKey:@"userID"] password:[[NSUserDefaults standardUserDefaults] stringForKey:@"userPW"] error:&error];
    if (!error) {
        //성공
        NSLog(@"로그인 성공 : %@", [[BaasioUser currentUser]description] );
        [BaasioPush registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert];

        [self goToMainPage];
    } else {
        //실패
        NSLog(@"Error: %@", error.localizedDescription);
    }
}
-(void)goToMainPage{
    NSMutableArray *vcs = [NSMutableArray array];
    
    //Creating view
    UserViewController *userView = [[UserViewController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:userView];
    //Dictionary of the view and title
    NSDictionary *view1 = [NSDictionary dictionaryWithObjectsAndKeys:nav1, @"vc", [[BaasioUser currentUser] objectForKey:@"name"], @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view1];
    
    //Creating view
    NewsFeedController *feedView = [[NewsFeedController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:feedView];
    //Dictionary of the view and title
    NSDictionary *view2 = [NSDictionary dictionaryWithObjectsAndKeys:nav2, @"vc", @"뉴스피드", @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view2];
    
    //Creating view
    AddFriendController *addFriendView = [[AddFriendController alloc] init];
    //Navigation Controller is required
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:addFriendView];
    //Dictionary of the view and title
    NSDictionary *view3 = [NSDictionary dictionaryWithObjectsAndKeys:nav3, @"vc", @"친구추가", @"title", nil];
    //And we finally add it to the array
    [vcs addObject:view3];
    
    SHSidebarController *sidebar = [[SHSidebarController alloc] initWithArrayOfVC:vcs];
    self.window.rootViewController = sidebar;
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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

//앱을 실행하고 있는 도중에 RemoteNotification 을 수신
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@",userInfo);
    //	NSLog(@"1. didReceiveRemoteNotification");
	// push 메시지 추출
//    NSDictionary *aps = [userInfo objectForKey:@"aps"];
	
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
    
    //tag가 필요하면 추가합니다
    NSArray *tags = @[[NSString stringWithFormat:@"t%@",[[BaasioUser currentUser] objectForKey:@"username"]]];
    
    //push를 보냅니다
    BaasioPush *push = [[BaasioPush alloc] init];
    [push didRegisterForRemoteNotifications:deviceToken
                                       tags:tags
                               successBlock:^(void) {
                                   NSLog(@"baas.io에 device가 등록됨");
                               }
                               failureBlock:^(NSError *error) {
                                   NSLog(@"e id : %@", error.uuid);
                                   NSLog(@"device등록 실패 : %@", error.localizedDescription);
                                   
                               }];
}

// APNS 에 RemoteNotification 등록 실패
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	NSLog(@"Error in registration. Error: %@", error);
}


@end
