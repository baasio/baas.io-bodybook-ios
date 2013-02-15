//
//  NewsFeedController.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 5..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface NewsFeedController : UITableViewController <MWPhotoBrowserDelegate>{
    NSArray *photos;
    NSMutableArray *contentArray;
}
@property (nonatomic, retain) NSArray *photos;
@end
