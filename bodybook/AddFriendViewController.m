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

@synthesize friendTextField;

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
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"친구";
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    [bt setBackgroundImage:[UIImage imageNamed:@"rightButton@2x.png"] forState:UIControlStateNormal];
    [bt setTitle:@"+" forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(addPeople) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)addPeople{
    // Parsing rpcData to JSON!
    if(![friendTextField.text isEqualToString:@""]) {
        BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/following/user/%@",[[BaasioUser currentUser]objectForKey:@"username"],[friendTextField text]]];
        [entity saveInBackground:^(BaasioEntity *entity) {
            NSLog(@"success : %@", entity.description);
        }
                    failureBlock:^(NSError *error) {
                        NSLog(@"fail : %@", error.localizedDescription);
                    }];
        

    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:[NSString stringWithFormat:@"Username을 입력하세요"]
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
