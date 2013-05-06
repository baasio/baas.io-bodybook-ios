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

-(NSString *)calculateDate:(NSDate *)date{
    NSString *interval;
    int diffSecond = (int)[date timeIntervalSinceNow];
    
    if (diffSecond < 0) { //입력날짜가 과거
        
        //날짜 차이부터 체크
        int valueInterval;
        int valueOfToday, valueOfTheDate;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        NSString *currentLanguage = [languages objectAtIndex:0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage]];
        
        [formatter setDateFormat:@"yyyyMMdd"];
        
        NSDate *now = [NSDate date];
        valueOfToday = [[formatter stringFromDate:now] intValue]; //오늘날짜
        valueOfTheDate = [[formatter stringFromDate:date] intValue]; //입력날짜
        valueInterval = valueOfToday - valueOfTheDate; //두 날짜 차이
        
        
        if(valueInterval == 1){
            [formatter setDateFormat:@"어제 a h:mm"];
            interval = [formatter stringFromDate:date];
        }else if(valueInterval == 2){
            [formatter setDateFormat:@"2일전 a h:mm"];
            interval = [formatter stringFromDate:date];
        }else if(valueInterval == 3){
            [formatter setDateFormat:@"3일전 a h:mm"];
            interval = [formatter stringFromDate:date];
        }
        else if(valueInterval > 3) { //4일 이상일때는 그냥 요일, 날짜 표시
            if ([currentLanguage compare:@"ko"] == NSOrderedSame)
                [formatter setDateFormat:@"MMM d일, EEEE"]; //locale 한국일 경우 "년, 일" 붙이기
            else
                [formatter setDateFormat:@"yyyy. MMM d, EEEE"];
            interval = [formatter stringFromDate:date];
        }
        else { //날짜가 같은경우 시간 비교
            
            [formatter setDateFormat:@"HH"];
            
            valueOfToday = [[formatter stringFromDate:now] intValue]; //오늘시간
            valueOfTheDate = [[formatter stringFromDate:date] intValue]; //입력시간
            valueInterval = valueOfToday - valueOfTheDate; //두 시간 차이
            
            if(valueInterval == 1)
                interval = @"1시간전";
            else if(valueInterval >= 2)
                interval = [NSString stringWithFormat:@"%i시간전", valueInterval];
            else { //시간이 같은 경우 분 비교
                
                [formatter setDateFormat:@"mm"];
                
                valueOfToday = [[formatter stringFromDate:now] intValue]; //오늘분
                valueOfTheDate = [[formatter stringFromDate:date] intValue]; //입력분
                valueInterval = valueOfToday - valueOfTheDate; //두 분 차이    
                
                if(valueInterval == 1)
                    interval = @"1분전";
                else if(valueInterval >= 2)
                    interval = [NSString stringWithFormat:@"%i분전", valueInterval];
                else //분이 같은 경우 차이가 1분 이내
                    interval = @"지금 등록";
                
            }
            
        }
        
    }
    else { //입력날짜가 미래
        NSLog(@"%s, 입력된 날짜가 미래임", __func__);
        interval = @"지금 등록";
    }
    return interval;
}

- (void)initCustomCell:(NSDictionary*)contentDic{
    userInfo = contentDic;
    contentUUID = [userInfo objectForKey:@"uuid"];
    NSDictionary *actorInfo = [userInfo objectForKey:@"actor"];
    
//    실시간 유저프로필 미반영
//    [profileImage setClipsToBounds:YES];
//    [profileImage setImageWithURL:[NSURL URLWithString:[actorInfo objectForKey:@"picture"]] placeholderImage:nil];
    
    //실시간 유저프로필 반영 (셀이 reuse될때마다 이미지를 부르게 된다)
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
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
//    [dateFormat setDateFormat:@"yyyy년 MM월 dd일 HH시 mm분 ss초-에 작성됨"];
//    [dateLabel setText:[[dateFormat stringFromDate:date]uppercaseString]];
    [dateLabel setText:[self calculateDate:date]];
    
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
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height+10, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.bottomView.frame.origin.y + 12)];
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
        [self.contentImageView setFrame:CGRectMake(self.contentImageView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height+10, self.contentImageView.frame.size.width, 180)];
        [self.imageContentButton setClipsToBounds:YES];
        [self.imageContentButton setFrame:CGRectMake(self.contentImageView.frame.origin.x, self.contentText.frame.origin.y + self.contentText.frame.size.height, self.contentImageView.frame.size.width, 180)];
        
        [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x, contentImageView.frame.origin.y + self.contentImageView.frame.size.height+10, self.bottomView.frame.size.width, self.bottomView.frame.size.height)];
        
        [self.background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.bottomView.frame.origin.y + 12)];
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
