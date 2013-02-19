//
//  UserViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 5..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "EGORefreshTableHeaderView.h"


@interface UserViewController : UITableViewController <MWPhotoBrowserDelegate,EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSArray *photos;
    NSMutableArray *contentArray;
    BOOL modalPageUP;
}
@property (nonatomic, retain) NSArray *photos;
-(void)updateFeedData;
@end
