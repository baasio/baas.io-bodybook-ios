//
//  FriendTableViewCell.h
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 22..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell {
    
}

@property (nonatomic, retain)IBOutlet UIImageView *image;
@property (nonatomic, retain)IBOutlet UILabel *userName,*name;
@property (nonatomic, retain)IBOutlet UIButton *addButton;

@end
