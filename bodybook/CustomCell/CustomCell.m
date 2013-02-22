//
//  CustomCell.m
//  customTableview
//
//  Created by gyuchan jeon on 12. 10. 9..
//  Copyright (c) 2012년 gyuchan jeon. All rights reserved.
//

#import "CustomCell.h"

#import "PostMessageViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import <baas.io/Baas.h>


@implementation CustomCell

@synthesize userInfo,name, contentText, bottomView, background, likeLabel, contentImageView, profileImage, badLabel, dateLabel, likeButton, badButton, imageContentButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)likeTouched:(id)sender{
    [likeButton setEnabled:NO];
    likeNumber++;
    BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/feed",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
    entity.uuid = contentUUID;
    [entity setObject:[NSString stringWithFormat:@"%d", likeNumber] forKey:@"like"];
    [entity updateInBackground:^(BaasioEntity *entity) {
        //NSLog(@"entity : %@", entity.description);
        NSLog(@"좋아요!+1");
        if(likeNumber>0){
            [likeLabel setText:[NSString stringWithFormat:@"%d",likeNumber]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"좋아요!를 눌렀습니다."
                                                        delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"확인", nil];
        [alert show];
    }
                    failureBlock:^(NSError *error) {
                        [likeButton setEnabled:YES];
                        NSLog(@"fail : %@", error.localizedDescription);
                    }];
}

- (IBAction)badTouched:(id)sender{
    [badButton setEnabled:NO];
    badNumber++;
    BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/feed",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
    entity.uuid = contentUUID;
    [entity setObject:[NSString stringWithFormat:@"%d", badNumber] forKey:@"bad"];
    [entity updateInBackground:^(BaasioEntity *entity) {
        //NSLog(@"entity : %@", entity.description);
        NSLog(@"싫어요!+1");
        if(badNumber>0){
            [badLabel setText:[NSString stringWithFormat:@"%d",badNumber]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"싫어요!를 눌렀습니다."
                                                        delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"확인", nil];
        [alert show];
    }
                  failureBlock:^(NSError *error) {
                      [badButton setEnabled:YES];
                      NSLog(@"fail : %@", error.localizedDescription);
                  }];
}

- (void)initCustomCell:(NSDictionary*)contentDic{
    userInfo = contentDic;
    NSDictionary *actorInfo = [userInfo objectForKey:@"actor"];
    contentUUID = [userInfo objectForKey:@"uuid"];
    
    if(postUserInfo == nil){
        BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
        [query setWheres:[NSString stringWithFormat:@"username = '%@'",[actorInfo objectForKey:@"username"]]];
        [query queryInBackground:^(NSArray *array) {
            NSMutableArray *postUser = [NSMutableArray arrayWithArray:array];
            postUserInfo = [[NSDictionary alloc]init];
            postUserInfo = [postUser objectAtIndex:0];
            [profileImage setClipsToBounds:YES];
            [profileImage setImageWithURL:[NSURL URLWithString:[postUserInfo objectForKey:@"picture"]] placeholderImage:nil];
        }
                    failureBlock:^(NSError *error) {
                        NSLog(@"fail : %@", error.localizedDescription);
                    }];
    }
    
    [contentText setText:[userInfo objectForKey:@"content"]];
    [name setText:[userInfo objectForKey:@"nameID"]];
    
    //시간 계산    
    long long timeStamp = [[userInfo objectForKey:@"created"] longLongValue];
    NSTimeInterval timeInterval = (double)(timeStamp/1000);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy년 MM월 dd일 HH시 mm분 ss초-에 작성됨"];
    [dateLabel setText:[[dateFormat stringFromDate:date]uppercaseString]];
    if([[userInfo objectForKey:@"like"] isEqualToString:@"0"]){
        likeNumber = 0;
        [likeLabel setText:@"-"];
    }else{
        likeNumber = [[userInfo objectForKey:@"like"] intValue];
        [likeLabel setText:[NSString stringWithFormat:@"%d",likeNumber]];
    }
    
    if([[userInfo objectForKey:@"bad"] isEqualToString:@"0"]){
        badNumber = 0;
        [badLabel setText:@"-"];
    }else{
        badNumber = [[userInfo objectForKey:@"bad"] intValue];
        [badLabel setText:[NSString stringWithFormat:@"%d",badNumber]];
    }
    
    CGSize size = [[userInfo objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(285, 9000)];
    CGFloat labelHeight = MAX(size.height, 10.0);
    [self.contentText setFont:[UIFont systemFontOfSize:13.0]];
    [self.contentText setLineBreakMode:NSLineBreakByCharWrapping];
    [self.contentText setNumberOfLines:0];
    [self.contentText setFrame:CGRectMake(self.contentText.frame.origin.x, self.contentText.frame.origin.y, self.contentText.frame.size.width, labelHeight+5.0)];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.4];
    
    if([[userInfo objectForKey:@"contentImagePath"] isEqualToString:@"-"]){
        //사진이 없는경우
        self.contentImageView.hidden = YES;
        self.imageContentButton.enabled = NO;
        self.imageContentButton.hidden = YES;
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.contentText.frame.origin.y + self.contentText.frame.size.height+12)];
    }else{
        //사진이 있는경우
        /////////////////// 이미지파일이 있는 URL주소///////////////////////////
        NSString *contentImagePath = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"contentImagePath"]];
        //////////////////////////////////////////////////////////////////
        
        self.contentImageView.hidden = NO;
        self.imageContentButton.enabled = YES;
        self.imageContentButton.hidden = NO;
        [self.contentImageView setImageWithURL:[NSURL URLWithString:contentImagePath]];
        [self.contentImageView setClipsToBounds:YES];
        [self.contentImageView setFrame:CGRectMake(self.contentImageView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.contentImageView.frame.size.width, 180)];
        [self.imageContentButton setClipsToBounds:YES];
        [self.imageContentButton setFrame:CGRectMake(self.contentImageView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.contentImageView.frame.size.width, 180)];
        
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height + self.contentImageView.frame.size.height, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.contentText.frame.origin.y + self.contentText.frame.size.height + self.contentImageView.frame.size.height+12)];
    }
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.background.bounds];
    self.background.layer.masksToBounds = NO;
    self.background.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.background.layer.shadowOpacity = 1.0;
    self.background.layer.shadowRadius = 1.5;
    self.background.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.background.layer.shadowPath = shadowPath.CGPath;
    self.background.layer.shouldRasterize = YES;
}
@end
