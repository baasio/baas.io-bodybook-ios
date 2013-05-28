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
#import "CommentViewController.h"

#import <baas.io/Baas.h>
#import <QuartzCore/QuartzCore.h>


@interface UserViewController ()

@end

@implementation UserViewController

@synthesize photos;

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
    if(modalPageUP){
        [self updateFeedData];
        modalPageUP = NO;
        contentEndCheck = NO;
    }
    [self.tableView reloadData];
    //[self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
    //[self updateFeedData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageNumber = 10;
    [self loadingViewStart];
    BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/activities",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
    [query setLimit:pageNumber];
    [query queryInBackground:^(NSArray *array) {
        if([contentArray isEqual:[[NSMutableArray alloc]initWithArray:array]] && pageNumber != 10){
            contentEndCheck = YES;
        }else{
            contentEndCheck = NO;
            contentArray = [[NSMutableArray alloc]initWithArray:array];
            [self.tableView reloadData];
        }
        if(_reloading == YES){
            [self doneLoadingTableViewData];
        }
        [self loadingViewEnd];
    }
                failureBlock:^(NSError *error) {
                    [self loadingViewEnd];
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
    
    modalPageUP = NO;
    contentEndCheck = NO;
    self.navigationItem.title = [[BaasioUser currentUser] objectForKey:@"name"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    UIButton *btnPost =[[UIButton alloc] init];
    [btnPost setBackgroundImage:[UIImage imageNamed:@"button@2x.png"] forState:UIControlStateNormal];
    UILabel *btnText = [[UILabel alloc]init];
    [btnText setText:@"게시"];
    [btnText setFont:[UIFont boldSystemFontOfSize:13]];
    [btnText setTextColor:[UIColor whiteColor]];
    [btnText setFrame:CGRectMake(0, 0, 50, 30)];
    [btnText setTextAlignment:NSTextAlignmentCenter];
    [btnText setBackgroundColor:[UIColor clearColor]];
    [btnPost addSubview:btnText];
    
    btnPost.frame = CGRectMake(100, 100, 50, 30);
    UIBarButtonItem *postBarButton =[[UIBarButtonItem alloc] initWithCustomView:btnPost];
    [btnPost addTarget:self action:@selector(postingPage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = postBarButton;
    
    UIImage *navBackground =[[UIImage imageNamed:@"navigationBar@2x.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController.navigationBar setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
}

-(void)loadingViewStart{
    indecatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 115.0f, 35.0f)];
    //indecatorView.backgroundColor = [UIColor colorWithRed:245.0f green:245.0f blue:245.0f alpha:1.0f];
    indecatorView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.9f];;
    indecatorView.layer.masksToBounds = YES;
    indecatorView.layer.cornerRadius = 5.0f;
    indecatorView.alpha = 0;
    
    [self.view addSubview:indecatorView];
    
    //indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(10.0f, 8.0f, 20.0f, 20.0f);
    activityIndicator.hidesWhenStopped = YES;
    
    [indecatorView addSubview:activityIndicator];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45.0f, 11.0f, 100.0f, 15.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"로딩중입니다";
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = [UIColor whiteColor];
    
    [indecatorView addSubview:label];
    indecatorView.center = self.view.center;
    indecatorView.transform = CGAffineTransformMakeScale(1.2f,1.2f);
    
    //애니메이션 구현
    [UIProgressView beginAnimations:nil context:nil];
    [UIProgressView setAnimationDuration:0.5];
    [UIProgressView setAnimationDelay:0.3];
    indecatorView.transform = CGAffineTransformMakeScale(1.0f,1.0f);
    indecatorView.alpha = 1;
    [UIProgressView commitAnimations];
    [activityIndicator startAnimating];
}
-(void)loadingViewEnd{
    //애니메이션 구현
    [UIProgressView beginAnimations:nil context:nil];
    [UIProgressView setAnimationDuration:0.5];
    indecatorView.transform = CGAffineTransformMakeScale(1.2f,1.2f);
    indecatorView.alpha = 0;
    [UIProgressView commitAnimations];
    [activityIndicator startAnimating];
}

-(void)updateFeedData{
    BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/activities",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
    [query setLimit:pageNumber];
    [query queryInBackground:^(NSArray *array) {
        if([contentArray isEqual:[[NSMutableArray alloc]initWithArray:array]] && pageNumber != 10){
            contentEndCheck = YES;
        }else{
            contentEndCheck = NO;
            contentArray = [[NSMutableArray alloc]initWithArray:array];
            [self.tableView reloadData];
        }
        if(_reloading == YES){
            [self doneLoadingTableViewData];
        }
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
}

-(void)postingPage{
    modalPageUP = YES;
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
            [cell.imageContentButton addTarget:self action:@selector(contentImageTouched:) forControlEvents:UIControlEventTouchUpInside];
            [[cell.commentButton layer]setValue:object forKey:@"object"];
            [cell.commentButton addTarget:self action:@selector(commentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [cell.profileImageButton addTarget:self action:@selector(profileImageTouched:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
            break;
    }
}
- (void)commentButtonTouched:(id)sender{
    CommentViewController *commentView = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];    [commentView initWithData:[[sender layer]valueForKey:@"object"]];
    [self.navigationController pushViewController:commentView animated:YES];
    //    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)contentImageTouched:(id)sender{
    CustomCell *customCell = (CustomCell *)[[sender superview] superview] ;
    
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    NSLog(@"%@",[customCell.userInfo objectForKey:@"contentImagePath"]);
    //photo = [MWPhoto photoWithURL:[NSURL URLWithString:[customCell.userInfo objectForKey:@"contentImagePath"]]];
    photo = [MWPhoto photoWithImage:customCell.contentImageView.image];
    photo.caption = customCell.contentText.text;
    [photoArray addObject:photo];
    self.photos = photoArray;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    NSLog(@"터치됨");
}

- (void)profileImageTouched:(id)sender{
    CustomCell *customCell = (CustomCell *)[[sender superview] superview] ;
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    NSLog(@"%@",[customCell.userInfo objectForKey:@"contentImagePath"]);
    //photo = [MWPhoto photoWithURL:[NSURL URLWithString:[customCell.userInfo objectForKey:@"contentImagePath"]]];
    photo = [MWPhoto photoWithImage:customCell.profileImage.image];
    photo.caption = customCell.name.text;
    [photoArray addObject:photo];
    self.photos = photoArray;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)return 292;
    NSDictionary *object = [contentArray objectAtIndex:indexPath.row-1];
    NSString *contentText = [object objectForKey:@"content"];
    if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 105;
    }else{
        //사진이 있는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 295;
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"끝이보임! 보이는 테이블 %d pageNumber:%d",((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row,pageNumber);
    //    if(((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row <= 8){
    //        NSLog(@"리로드활성화");
    //        pageNumber = pageNumber+10;
    //        [self updateFeedData];
    //    }
    
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 3) {
        if(!contentEndCheck){
            pageNumber = pageNumber+10;
            [self updateFeedData];
            NSLog(@"리로드활성화");
        }
        // This is the last cell in the table
    }
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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    pageNumber = 10;
    [self updateFeedData];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
    [self.tableView reloadData];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}

@end
