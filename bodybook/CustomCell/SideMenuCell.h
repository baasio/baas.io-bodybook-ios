//
//  SideMenuCell.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 26..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell {
    UILabel *menuName;
    UIImageView *menuImage;
}

@property (nonatomic,retain)UILabel *menuName;
@property (nonatomic,retain)UIImageView *menuImage;

@end
