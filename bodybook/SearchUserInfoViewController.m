//
//  SearchUserInfoViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 25..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "SearchUserInfoViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <baas.io/Baas.h>

@interface SearchUserInfoViewController ()

@end

@implementation SearchUserInfoViewController

@synthesize profileImage,addFriend,name,profileImageTouched;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initWithUserinfo:(NSDictionary*)info{
    NSLog(@"%@",[info objectForKey:@"picture"]);
    userInfo = info;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *navBackground =[[UIImage imageNamed:@"navigationBar@2x.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    
    UIButton *btnBack =[[UIButton alloc] init];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"backButton@2x.png"] forState:UIControlStateNormal];
    UILabel *btnText2 = [[UILabel alloc]init];
    [btnText2 setText:@"뒤로"];
    [btnText2 setFont:[UIFont boldSystemFontOfSize:13]];
    [btnText2 setTextColor:[UIColor whiteColor]];
    [btnText2 setFrame:CGRectMake(3, 0, 50, 30)];
    [btnText2 setTextAlignment:NSTextAlignmentCenter];
    [btnText2 setBackgroundColor:[UIColor clearColor]];
    [btnBack addSubview:btnText2];
    
    btnBack.frame = CGRectMake(100, 100, 50, 30);
    UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [btnBack addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:backBarButton];

    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    [profileImageTouched addTarget:self action:@selector(profileImageView) forControlEvents:UIControlEventTouchUpInside];
    [profileImage setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"picture"]] placeholderImage:nil];
    [profileImage setClipsToBounds:YES];
    [name setText:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]]];
    
    [addFriend addTarget:self action:@selector(addFriendTouched) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
}

- (void)backButtonTouched{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addFriendTouched{
    BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/following/user/%@",[[BaasioUser currentUser]objectForKey:@"username"],[userInfo objectForKey:@"username"]]];
    [entity saveInBackground:^(BaasioEntity *entity) {
        NSLog(@"친구추가 성공");
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
}


- (void)profileImageView{
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    //photo = [MWPhoto photoWithURL:[NSURL URLWithString:[customCell.userInfo objectForKey:@"contentImagePath"]]];
    photo = [MWPhoto photoWithImage:profileImage.image];
    [photoArray addObject:photo];
    photos = photoArray;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    NSLog(@"%d",photos.count);
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

@end
