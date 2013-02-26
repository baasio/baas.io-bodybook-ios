//
//  SideMenuCell.m
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 26..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "SideMenuCell.h"

@implementation SideMenuCell

@synthesize menuName,menuImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        menuName = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 44)];
        [menuName setTextAlignment:NSTextAlignmentLeft];
        [menuName setTextColor:[UIColor whiteColor]];
        [menuName setBackgroundColor:[UIColor clearColor]];
        [menuName setFont:[UIFont systemFontOfSize:17]];
        
        menuImage = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, 36, 36)];
        [menuImage setClipsToBounds:YES];
        
        [self.contentView addSubview:menuImage];
        [self.contentView addSubview:menuName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
