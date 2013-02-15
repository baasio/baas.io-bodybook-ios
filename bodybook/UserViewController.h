//
//  UserViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 5..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface UserViewController : UITableViewController <MWPhotoBrowserDelegate>{
    NSArray *photos;
    NSMutableArray *contentArray;
}
@property (nonatomic, retain) NSArray *photos;
-(void)updateFeedData;
@end
