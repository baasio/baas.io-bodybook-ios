//
//  SearchUserInfoViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 25..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface SearchUserInfoViewController : UIViewController <MWPhotoBrowserDelegate>{
    UIImageView *profileImage;
    UILabel *name;
    UIButton *addFriend;
    UIButton *profileImageTouched;
    NSDictionary *userInfo;
    
    NSArray *photos;
}

@property (nonatomic, retain)IBOutlet UIImageView *profileImage;
@property (nonatomic, retain)IBOutlet UILabel *name;
@property (nonatomic, retain)IBOutlet UIButton *addFriend,*profileImageTouched;

- (void)initWithUserinfo:(NSDictionary*)info;

@end
