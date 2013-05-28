//
//  AddFriendViewController.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 18..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "AddFriendViewController.h"
#import "SearchUserInfoViewController.h"

#import <baas.io/Baas.h>

@interface AddFriendViewController ()

@end


@implementation AddFriendViewController

@synthesize friendTextField,closeTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    friendTextField.text = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"친구";
    [friendTextField setReturnKeyType:UIReturnKeyGo];    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    UIImage *navBackground =[[UIImage imageNamed:@"navigationBar@2x.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    
    [friendTextField setEnablesReturnKeyAutomatically:YES];
    [closeTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnSearch =[[UIButton alloc] init];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"button@2x.png"] forState:UIControlStateNormal];
    UILabel *btnText = [[UILabel alloc]init];
    [btnText setText:@"검색"];
    [btnText setFont:[UIFont boldSystemFontOfSize:13]];
    [btnText setTextColor:[UIColor whiteColor]];
    [btnText setFrame:CGRectMake(0, 0, 50, 30)];
    [btnText setTextAlignment:NSTextAlignmentCenter];
    [btnText setBackgroundColor:[UIColor clearColor]];
    [btnSearch addSubview:btnText];
    
    btnSearch.frame = CGRectMake(100, 100, 50, 30);
    UIBarButtonItem *searchBarButton =[[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    [btnSearch addTarget:self action:@selector(addMyFriend) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = searchBarButton;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)hideKeyboard{
    [friendTextField resignFirstResponder];
}


- (void)addMyFriend{
    if(![friendTextField.text isEqualToString:@""]) {
        BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@",[friendTextField text]]];
        [entity saveInBackground:^(BaasioEntity *entity) {
            //NSLog(@"success : %@", entity.description);
            [friendTextField resignFirstResponder];
            SearchUserInfoViewController *viewController = [[SearchUserInfoViewController alloc] init];
            [viewController initWithUserinfo:entity.dictionary];
            [self.navigationController pushViewController:viewController animated:YES];
        }
                    failureBlock:^(NSError *error) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                       message:[NSString stringWithFormat:@"입력하신 아이디로 등록한 회원이 없거나 검색이 허용되지 않는 회원입니다"]
                                                                      delegate:self
                                                             cancelButtonTitle:@"확인"
                                                             otherButtonTitles:nil];
                        
                        [alert show];
                        NSLog(@"fail : %@", error.localizedDescription);
                    }];
        
        
    } else {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.text stringByReplacingCharactersInRange:range withString:string].length >= 1) {
        self.navigationItem.rightBarButtonItem.enabled = YES;

        
//        BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
//        NSString *whereQueryString = [NSString stringWithFormat:@"username = '%@'",friendTextField.text];
//        [query setWheres:whereQueryString];
//        [query queryInBackground:^(NSArray *array) {
//            if([array count]>0){
//            }
//            //NSLog(@"array : %@", contentArray);
//        }
//                    failureBlock:^(NSError *error) {
//                        NSLog(@"친구를 찾지 못함 : %@", error.localizedDescription);
//                    }];

    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    if (textFieldView == friendTextField) {
        if([friendTextField.text isEqualToString:[[BaasioUser currentUser]objectForKey:@"username"]]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:[NSString stringWithFormat:@"자기 자신을 검색하시면 안됩니다"]
                                                          delegate:self
                                                 cancelButtonTitle:@"확인"
                                                 otherButtonTitles:nil];

            [alert show];
        }else{
            [self addMyFriend];
        }
        
    }
    return YES;
}

@end
