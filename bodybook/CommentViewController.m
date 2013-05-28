//
//  CommentViewController.m
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 6..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "CommentViewController.h"
#import "CustomCell.h"
#import "CommentCell.h"

#import <QuartzCore/QuartzCore.h>
#import <baas.io/Baas.h>

@interface CommentViewController ()

@end

@implementation CommentViewController
@synthesize customTableView, photos, doneBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];
        
        [self.view addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
    }
    return self;
}

-(void)dismissKeyboard {
    [textView setText:@""];
    [textView resignFirstResponder];
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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadSetView
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 3;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    
//    textView. = @"댓글을 달아보세요.";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"게시" forState:UIControlStateNormal];

    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
    [doneBtn setEnabled:NO];
    
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:containerView];

}
- (void)initWithData:(NSDictionary *)object{
    [self loadingViewStart];
    
    contentArray = object;
    
    NSLog(@"원글 UUID : %@", [contentArray objectForKey:@"uuid"]);
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"Comments"];
    [query setLimit:999];
    [query setWheres:[NSString stringWithFormat:@"feedUUID = %@",[contentArray objectForKey:@"uuid"]]];
    [query queryInBackground:^(NSArray *array) {
        [self loadingViewEnd];
        commentArray = [[NSMutableArray alloc]initWithArray:array];
        NSLog(@"댓글 : %@", array.description);
        [customTableView reloadData];
        if (customTableView.contentSize.height > customTableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, customTableView.contentSize.height - customTableView.frame.size.height);
            [customTableView setContentOffset:offset animated:YES];
        }
//        NSLog(@"%d",commentArray.count);
    }
                failureBlock:^(NSError *error) {
                    [self loadingViewEnd];
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSetView];
    
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
    
    self.customTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.customTableView.backgroundColor = [UIColor clearColor];
    self.customTableView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:1.0 alpha:1];
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

-(void)resignTextView
{
    [doneBtn setEnabled:NO];
    BaasioEntity *entity = [BaasioEntity entitytWithName:@"Comments"];
    [entity setObject:[textView text] forKey:@"content"];
    [entity setObject:[contentArray objectForKey:@"uuid"] forKey:@"feedUUID"];
    [entity setObject:[BaasioUser currentUser] forKey:@"writer"];
    [entity saveInBackground:^(BaasioEntity *entity) {
        [textView setText:@""];
        [textView resignFirstResponder];
        [self initWithData:contentArray];
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	[customTableView setFrame:CGRectMake(customTableView.frame.origin.x, customTableView.frame.origin.y, customTableView.frame.size.width, customTableView.frame.size.height - (keyboardBounds.size.height))];
	// set views with new info
	containerView.frame = containerFrame;

    if (customTableView.contentSize.height > customTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, customTableView.contentSize.height - customTableView.frame.size.height);
        [customTableView setContentOffset:offset animated:NO];
    }

	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    containerView.frame = containerFrame;
    
	[customTableView setFrame:CGRectMake(customTableView.frame.origin.x, customTableView.frame.origin.y, customTableView.frame.size.width, customTableView.frame.size.height + (keyboardBounds.size.height))];
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int lenght = growingTextView.text.length - range.length + text.length;
    if (lenght >0) {
        [doneBtn setEnabled:YES];
    }
    else {
        [doneBtn setEnabled:NO];
    }
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[NSDictionary alloc]init];
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    static NSString *CellIdentifier2 = @"CommentCell";
    CommentCell *commentCell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    if(indexPath.row == 0){
        object = contentArray;
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
        cell = [nibs objectAtIndex:0];
        [cell initCustomCell:object];
        [cell.imageContentButton addTarget:self action:@selector(contentImageTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentButton addTarget:self action:@selector(commentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        if([commentArray objectAtIndex:indexPath.row-1]){
            object = [commentArray objectAtIndex:indexPath.row-1];
            NSArray *nibs2 = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:nil options:nil];
            commentCell = [nibs2 objectAtIndex:0];
            [commentCell initCommentCell:object];
            return commentCell;
        }
        return nil;
    }
}

- (void)commentButtonTouched:(id)sender{
    [textView becomeFirstResponder];
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
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = contentArray;
    NSString *contentText = [object objectForKey:@"content"];    
    if(indexPath.row == 0){
        if([[object objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
            //사진이 없는경우
            CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                                  constrainedToSize:CGSizeMake(285, 9000)];
            return size.height + 108;
        }else{
            //사진이 있는경우
            CGSize size = [contentText sizeWithFont:[UIFont systemFontOfSize:13]
                                  constrainedToSize:CGSizeMake(285, 9000)];
            return size.height + 298;
        }
    }else{
        NSDictionary *comment = [commentArray objectAtIndex:indexPath.row-1];
        NSString *commentText = [comment objectForKey:@"content"];
        CGSize size = [commentText sizeWithFont:[UIFont systemFontOfSize:13]
                              constrainedToSize:CGSizeMake(245, 9000)];
        return size.height + 52;
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

@end
