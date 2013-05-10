//
//  CommentViewController.h
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 6..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HPGrowingTextView.h"
#import "MWPhotoBrowser.h"

@interface CommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MWPhotoBrowserDelegate,HPGrowingTextViewDelegate>{
    UITableView *customTableView;
    
    NSDictionary *contentArray;
    NSMutableArray *commentArray;

    NSArray *photos;
    
    UIButton *doneBtn;
    UIView *containerView;
    HPGrowingTextView *textView;
    
    //////////////////////////////////////////////////
    UIActivityIndicatorView *activityIndicator;
    UIView *indecatorView;
    //////////////////////////////////////////////////
}

@property (nonatomic, retain)UIButton *doneBtn;
@property (nonatomic, retain)NSArray *photos;
@property (nonatomic, retain)IBOutlet UITableView *customTableView;

- (void)initWithData:(NSDictionary *)object;

- (void)resignTextView;

@end
