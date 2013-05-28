//
//  AddFriendController.m
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 22..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "AddFriendController.h"
#import "FriendTableViewCell.h"
#import <QuartzCore/QuartzCore.h>


#import <SDWebImage/UIImageView+WebCache.h>

#import <baas.io/Baas.h>

@interface AddFriendController ()

@end

@implementation AddFriendController

-(void)dismissKeyboard {
    [friendSearchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.navigationItem.title = @"친구찾기";
    
    friendsInfo = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [friendsInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userInfoCellIdentifier = @"FriendTableViewCell";
    FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:userInfoCellIdentifier];
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"FriendTableViewCell" owner:nil options:nil];
    cell = [nibs objectAtIndex:0];
    
    [cell.userName setText:[[friendsInfo objectAtIndex:indexPath.row] objectForKey:@"username"]];
    [cell.name setText:[[friendsInfo objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [cell.image setContentMode:UIViewContentModeScaleAspectFill];
    [cell.image setFrame:CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 44, 44)];
    [cell.image setClipsToBounds:YES];
    [cell.image setImageWithURL:[NSURL URLWithString:[[friendsInfo objectAtIndex:indexPath.row] objectForKey:@"picture"]]];
    
    [[cell.addButton layer]setValue:[friendsInfo objectAtIndex:indexPath.row] forKey:@"object"];
    [cell.addButton addTarget:self action:@selector(addButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)addButtonTouched:(id)sender{
    NSDictionary *userInfo = [[sender layer]valueForKey:@"object"];
    
    BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/following/user/%@",[[BaasioUser currentUser]objectForKey:@"username"],[userInfo objectForKey:@"username"]]];
    [entity saveInBackground:^(BaasioEntity *entity) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:[NSString stringWithFormat:@"친구추가 성공"]
                                                      delegate:self
                                             cancelButtonTitle:@"확인"
                                             otherButtonTitles:nil];
        
        [alert show];
    }
                failureBlock:^(NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"다시 시도하세요"]
                                                                  delegate:self
                                                         cancelButtonTitle:@"확인"
                                                         otherButtonTitles:nil];
                    
                    [alert show];
                }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(![searchText isEqualToString:@""]){
        BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users"]];
        [query setWheres:[NSString stringWithFormat:@"username = '%@*' or name = '%@*'",searchText,searchText]];
        [query setLimit:20];
        [query queryInBackground:^(NSArray *array) {
            friendsInfo = [[NSMutableArray alloc]initWithArray:array];
            [friendTableView reloadData];
        }
                     failureBlock:^(NSError *error) {
                         NSLog(@"친구 불러오기 실패 : %@", error.localizedDescription);
                     }];
    }
}

@end
