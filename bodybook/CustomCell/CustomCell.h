//
//  CustomCell.h
//  customTableview
//
//  Created by gyuchan jeon on 12. 10. 9..
//  Copyright (c) 2012년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell  {
    NSDictionary *userInfo;
    NSDictionary *postUserInfo;
    NSString *contentUUID;
    
    UILabel *name;
    UILabel *contentText;
    UILabel *likeLabel;
    UILabel *badLabel;
    UILabel *dateLabel;
    UIView *background;
    UIView *bottomView;
    UIImageView *imageView;
    UIImageView *profileImage;
    UIButton *likeButton;
    UIButton *badButton;
    
    
    BOOL firstLike;
    int likeNumber;
    BOOL firstBad;
    int badNumber;
}

@property (nonatomic, retain) IBOutlet UILabel *name, *contentText, *likeLabel, *badLabel, *dateLabel;
@property (nonatomic, retain) IBOutlet UIView *background, *bottomView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView, *profileImage;
@property (nonatomic, retain) IBOutlet UIButton *likeButton, *badButton;


- (void)initCustomCell:(NSDictionary*)contentDic;

@end
