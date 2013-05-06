//
//  CommentViewController.h
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 6..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MWPhotoBrowser.h"

@interface CommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,MWPhotoBrowserDelegate>{
    UITableView *customTableView;
    
    NSDictionary *contentArray;
    NSMutableArray *commentArray;

    NSArray *photos;
}

@property (nonatomic, retain)NSArray *photos;
@property (nonatomic, retain)IBOutlet UITableView *customTableView;

- (void)initWithData:(NSDictionary *)object;

@end
