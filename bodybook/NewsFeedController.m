//
//  NewsFeedController.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 5..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "NewsFeedController.h"
#import "CustomCell.h"
#import "UserViewController.h"
#import "PostMessageViewController.h"

#import <baas.io/Baas.h>

@interface NewsFeedController ()

@end

@implementation NewsFeedController

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
    if(postingPageUP){
        [self updateFeedData];
        postingPageUP = NO;
    }
    //[self.tableView reloadData];
    //[self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
    //[self updateFeedData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"%@",[BaasioUser currentUser]);
    
    [self updateFeedData];
    
    postingPageUP = NO;
    self.navigationItem.title = @"뉴스피드";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 29)];
    [bt setTitle:@"게시" forState:UIControlStateNormal];
    //[bt setImage:[UIImage imageNamed:@"newMessage@2x.png"] forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(postingPage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *src = [[UIBarButtonItem alloc] initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem = src;
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
}

-(void)updateFeedData{
    BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/following/user/",[[BaasioUser currentUser]objectForKey:@"username"]]];
    //limit이 걸리나? 그럼 10개한정이면 10명이상의 친구가 있을 경우는 어쩌지? 답 : next, preview기능이 있다.
    [query queryInBackground:^(NSArray *array) {
        NSMutableArray *friendArray = [[NSMutableArray alloc]initWithArray:array];
        NSDictionary *friendInfo = [[NSDictionary alloc]init];
        
        BaasioQuery *query = [BaasioQuery queryWithCollection:@"feed"];
        NSString *whereQueryString = [NSString stringWithFormat:@"username = '%@'",[[BaasioUser currentUser] objectForKey:@"username"]];
        for(int i=0;i<friendArray.count;i++){
            friendInfo = [friendArray objectAtIndex:i];
            whereQueryString = [whereQueryString stringByAppendingFormat:@" or username = '%@'",[friendInfo objectForKey:@"username"]];
        }
        [query setWheres:whereQueryString];
        [query setLimit:999];
        [query setOrderBy:@"created" order:BaasioQuerySortOrderDESC];
        [query queryInBackground:^(NSArray *array) {
            contentArray = [[NSMutableArray alloc]initWithArray:array];
            [self doneLoadingTableViewData];
            //NSLog(@"array : %@", contentArray);
        }
                    failureBlock:^(NSError *error) {
                        NSLog(@"뉴스피드 불러오기 실패 : %@", error.localizedDescription);
                    }];
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"친구목록 불러오기 실패 : %@", error.localizedDescription);
                }];
}

-(void)postingPage{
    postingPageUP = YES;
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
    return contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[NSDictionary alloc]init];
    if(contentArray.count>=1) {
        object = [contentArray objectAtIndex:indexPath.row];
    }
    
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
        cell = [nibs objectAtIndex:0];
        [cell initCustomCell:object];
        
    }
    [cell.imageContentButton addTarget:self action:@selector(contentImageTouched:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [contentArray objectAtIndex:indexPath.row];
    NSString *contentText = [object objectForKey:@"content"];
    if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 85;
    }else{
        //사진이 있는경우
        CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(285, 9000)];
        return size.height + 265;
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
