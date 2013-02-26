//
//  ProfileInfoCell.h
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 23..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileInfoCell : UITableViewCell <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIPageViewControllerDelegate>{
    NSDictionary *userInfo;
    UIViewController *viewController;
        
    UIButton *profileImageChangeButton;
    UIView *profileImageBackground;
    UIImageView *profileImage;
    UIImageView *profileBigImage;
    UIImage *uploadImage;
    UILabel *userNameLabel;
    UILabel *nameLabel;
    
    UIView *friendCountView;
    UILabel *followingCount;
    UILabel *followersCount;
}

@property (nonatomic, retain)IBOutlet UIButton *profileImageChangeButton;
@property (nonatomic, retain)IBOutlet UIView *profileImageBackground,*friendCountView;
@property (nonatomic, retain)IBOutlet UIImageView *profileImage, *profileBigImage;
@property (nonatomic, retain)IBOutlet UILabel *userNameLabel,*nameLabel,*followingCount,*followersCount;
@property (nonatomic, retain)UIViewController *viewController;

- (void)initCustomCell:(NSDictionary*)contentDic;
- (IBAction)profileImageChange:(id)sender;

@end
