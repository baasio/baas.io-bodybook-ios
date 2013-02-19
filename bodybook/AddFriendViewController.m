//
//  AddFriendViewController.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 18..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "AddFriendViewController.h"

#import <baas.io/Baas.h>

@interface AddFriendViewController ()

@end


@implementation AddFriendViewController

@synthesize friendTextField,addFriend,check,checkText,closeTextField;

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
    [checkText setText:@""];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"친구";
    [checkText setText:@""];
    [friendTextField setReturnKeyType:UIReturnKeyGo];
    
//    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
//    [bt setBackgroundImage:[UIImage imageNamed:@"rightButton@2x.png"] forState:UIControlStateNormal];
//    [bt setTitle:@"+" forState:UIControlStateNormal];
//    [bt addTarget:self action:@selector(addPeople) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
//    [bt setEnabled:FALSE];
//    self.navigationItem.rightBarButtonItem = src;
    
    [addFriend addTarget:self action:@selector(addMyFriend) forControlEvents:UIControlEventTouchUpInside];
    [closeTextField addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)hideKeyboard{
    [friendTextField resignFirstResponder];
}


- (void)addMyFriend{
    // Parsing rpcData to JSON!
    if(![friendTextField.text isEqualToString:@""]) {
        BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/following/user/%@",[[BaasioUser currentUser]objectForKey:@"username"],[friendTextField text]]];
        [entity saveInBackground:^(BaasioEntity *entity) {
            NSLog(@"success : %@", entity.description);
            [checkText setText:@"정상적으로 추가되었습니다"];
            [check setImage:[UIImage imageNamed:@"sign_in_correct@2x.png"]];
        }
                    failureBlock:^(NSError *error) {
                        [checkText setText:@"Username을 정확히 입력하세요"];
                        [check setImage:[UIImage imageNamed:@"sign_in_wrong@2x.png"]];
                        NSLog(@"fail : %@", error.localizedDescription);
                    }];
        

    } else {
        [checkText setText:@"Username을 입력하세요"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (friendTextField.text.length >= 1) {
        BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
        NSString *whereQueryString = [NSString stringWithFormat:@"username = '%@'",friendTextField.text];
        [query setWheres:whereQueryString];
        [query queryInBackground:^(NSArray *array) {
            if([array count]>0){
//                [self.navigationItem.rightBarButtonItem setEnabled:TRUE];
            }else{
//                [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
            }
            
            //NSLog(@"array : %@", contentArray);
        }
                    failureBlock:^(NSError *error) {
                        [addFriend setHidden:TRUE];
                        [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
                        NSLog(@"친구를 찾지 못함 : %@", error.localizedDescription);
                    }];

    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    if (textFieldView == friendTextField) {
        [self addMyFriend];
    }
    return YES;
}

@end
