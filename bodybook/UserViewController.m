//
//  UserViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 5..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "UserViewController.h"
#import "CustomCell.h"
#import "ProfileInfoCell.h"
#import "PostMessageViewController.h"

#import <baas.io/Baas.h>

@interface UserViewController ()

@end

@implementation UserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
    [self updateFeedData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [[BaasioUser currentUser] objectForKey:@"name"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    //[bt setImage:[UIImage imageNamed:@"newMessage@2x.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(postingPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;
}

-(void)updateFeedData{
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"feed"];
    [query setWheres:[NSString stringWithFormat:@"username = '%@'",[[BaasioUser currentUser] objectForKey:@"username"]]];
    //[query setLimit:2];
    [query setOrderBy:@"created" order:BaasioQuerySortOrderDESC];
    [query queryInBackground:^(NSArray *array) {
        contentArray = [[NSMutableArray alloc]initWithArray:array];
        [self.tableView reloadData];
        //NSLog(@"array : %@", contentArray);
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
}

-(void)postingPage{
    PostMessageViewController *postMessageView = [[PostMessageViewController alloc] initWithNibName:@"PostMessageViewController" bundle:nil];
    [self presentViewController:postMessageView animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contentArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[NSDictionary alloc]init];
    static NSString *userInfoCellIdentifier = @"ProfileInfoCell";
    ProfileInfoCell *userInfoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    switch (indexPath.row) {
        case 0:
            if(contentArray.count>=1) {
                object = [contentArray objectAtIndex:indexPath.row];
            }
            if (userInfoCell == nil){
                NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ProfileInfoCell" owner:nil options:nil];
                userInfoCell = [nibs objectAtIndex:0];
                userInfoCell.viewController = self;
                [userInfoCell initCustomCell:object];
            }else{
                userInfoCell.viewController = self;
                [userInfoCell initCustomCell:object];
            }
            return userInfoCell;
            break;
        default:
            if(contentArray.count>=1) {
                object = [contentArray objectAtIndex:indexPath.row-1];
            }
            if (cell == nil){
                NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
                cell = [nibs objectAtIndex:0];
                if(contentArray){
                    [cell initCustomCell:object];
                }
            }else{
                if(contentArray.count>=1){
                    [cell initCustomCell:object];
                }
            }
            return cell;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)return 245;
    NSDictionary *object = [contentArray objectAtIndex:indexPath.row-1];
    NSString *contentText = [object objectForKey:@"content"];
    if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 85;
    }else{
        //사진이 있는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 265;
    }
}

@end
