//
//  CommentCell.h
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 7..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell {
    IBOutlet UIView *background;
    NSDictionary *commentInfo;
    
    IBOutlet UILabel *name;
    IBOutlet UILabel *content;
    IBOutlet UILabel *time;
    IBOutlet UIImageView *profileImage;
}

@property (nonatomic, retain) IBOutlet UILabel *name, *content, *time;
@property (nonatomic, retain) IBOutlet UIView *background;
@property (nonatomic, retain) IBOutlet UIImageView *profileImage;
@property (nonatomic, retain) NSDictionary *commentInfo;

- (void)initCommentCell:(NSDictionary*)contentDic;

@end
