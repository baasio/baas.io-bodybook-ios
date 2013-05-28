//
//  ViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 4..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "ViewController.h"
#import "SHSidebarController.h"
#import "UserViewController.h"
#import "NewsFeedController.h"
#import "JoinController.h"
//#import "AddFriendViewController.h"
#import "AddFriendController.h"

#import <QuartzCore/QuartzCore.h>
#import <baas.io/Baas.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize bodybookTitle,textFileBackground,loginButton,userName,password,scrollView,joinButton;

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginButton.layer.cornerRadius = 6;
    loginButton.clipsToBounds = YES;
    
    joinButton.layer.cornerRadius = 6;
    joinButton.clipsToBounds = YES;
    
    [self.password setSecureTextEntry:YES];
    [self.userName setReturnKeyType:UIReturnKeyNext];
    [self.password setReturnKeyType:UIReturnKeyGo];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)loginTouched:(id)sender{
    [self login];
}
-(IBAction)joinTouched:(id)sender{
    JoinController *joinView = [[JoinController alloc] initWithNibName:@"JoinController" bundle:nil];
    [self presentViewController:joinView animated:YES completion:nil];
}
- (void)login{
    NSError *error;
    [BaasioUser signIn:userName.text password:password.text error:&error];
    if (!error) {
        //성공
        NSLog(@"로그인 성공 : %@", [[BaasioUser currentUser]description] );
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        [[NSUserDefaults standardUserDefaults] setObject:userName.text forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] setObject:password.text forKey:@"userPW"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    [self presentViewController:sidebar animated:NO completion:nil];
}




- (BOOL)textFieldShouldBeginEditing:(UITextField *)textFieldView {
    textFieldView.enablesReturnKeyAutomatically = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textFieldView {
    currentTextField = self.password;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    if (textFieldView == self.userName) {
        //[self.userName resignFirstResponder];
        [self.password becomeFirstResponder];
    } else if (textFieldView == self.password) {
        [self.password resignFirstResponder];
        [self login];
    }
    return YES;
}
- (IBAction) hideKeyboard : (id) sender {
    [userName resignFirstResponder];
    [password resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *) notification {
    if (keyboardIsShown) return;
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= keyboardRect.size.height;
    scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [currentTextField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    keyboardIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *) notification {
    NSDictionary* info = [notification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += keyboardRect.size.height;
    scrollView.frame = viewFrame;
    
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    keyboardIsShown = NO;
}





@end
