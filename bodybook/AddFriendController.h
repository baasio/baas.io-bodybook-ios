//
//  AddFriendController.h
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 22..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UISearchBar *friendSearchBar;
    IBOutlet UITableView *friendTableView;
    NSMutableArray *friendsInfo;
}


@end
