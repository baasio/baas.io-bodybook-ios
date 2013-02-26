//
//  MenuTVC.m
//  TVS
//
//  Created by Jorge Izquierdo on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHMenuTVC.h"
#import "SideMenuCell.h"
#import <QuartzCore/QuartzCore.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import <baas.io/Baas.h>

@implementation SHMenuTVC
@synthesize tableView;
-(id)initWithTitlesArray:(NSArray *)array andDelegate:(id<SHMenuDelegate>)del{
    
    self = [super init];
    
    if (self){
        delegate = del;
        titlesArray = array;
        self.view.frame = CGRectMake(0, 0, 161.5, 548);
    }
    return self;
}
- (void)viewDidLoad
{

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 162, [[UIScreen mainScreen] bounds].size.height - 20) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebarshadow"]];
    [shadow setFrame:CGRectMake(118, 0, 43.5, [[UIScreen mainScreen] bounds].size.height - 20)];
    [self.view addSubview:shadow];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *sbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebarbg"]];
    [sbg setFrame:CGRectMake(0, 0, 161.5, [[UIScreen mainScreen] bounds].size.height - 20)];
    [self.tableView setBackgroundView:sbg];
    self.view.backgroundColor = [UIColor clearColor];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [titlesArray count]-1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    SideMenuCell *cell = (SideMenuCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell =[[SideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebarcell"]];
    [bg setFrame:CGRectMake(0, 0, 161.5, 42.5)];
    
    switch (indexPath.section) {
        case 0:
            cell.menuName.text = [titlesArray objectAtIndex:indexPath.section + indexPath.row];
            [cell.menuImage setImageWithURL:[NSURL URLWithString:[[BaasioUser currentUser]objectForKey:@"picture"]] placeholderImage:nil];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.menuName.text = [titlesArray objectAtIndex:indexPath.section + indexPath.row];
                    cell.menuImage.image = [UIImage imageNamed:@"newsfeed_btn@2x.png"];
                    break;
                case 1:
                    cell.menuName.text = [titlesArray objectAtIndex:indexPath.section + indexPath.row];
                    cell.menuImage.image = [UIImage imageNamed:@"friend_search@2x.png"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    // Configure the cell...
    cell.backgroundView = bg;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        default:
            return 30;
            break;
    }
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 50, 20)];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:13]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setShadowColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
    [title setShadowOffset:CGSizeMake(1, 1)];
    switch (section) {
        case 0:
            [title setText:@"나"];
            break;
        case 1:
            [title setText:@"즐겨찾기"];
            break;
        default:
            break;
    }

    
    [headerView addSubview:title];
    headerView.backgroundColor = [UIColor brownColor];
    //headerImage.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 30);
    
    return headerView;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate respondsToSelector:@selector(didSelectElementAtIndex:)]){
        [delegate didSelectElementAtIndex:indexPath.section + indexPath.row];        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
