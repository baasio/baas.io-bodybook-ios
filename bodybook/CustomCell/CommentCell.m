//
//  CommentCell.m
//  bodybook
//
//  Created by Jeon Gyuchan on 13. 5. 7..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import "CommentCell.h"


#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@implementation CommentCell
@synthesize commentInfo,background,name,content,time,profileImage;

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

- (void)initCommentCell:(NSDictionary*)contentDic
{
    self.backgroundColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:.4];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [profileImage setFrame:CGRectMake(17, 7, 35, 35)];

    CGSize size = [[contentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(245, 9000)];
    CGFloat labelHeight = MAX(size.height, 5.0);
    [content setFont:[UIFont systemFontOfSize:13.0]];
    [content setLineBreakMode:NSLineBreakByCharWrapping];
    [content setNumberOfLines:0];
    [content setFrame:CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, labelHeight+5.0)];

    [time setFrame:CGRectMake(self.time.frame.origin.x, self.content.frame.origin.y + self.content.frame.size.height, self.time.frame.size.width, self.time.frame.size.height)];
    
    [background setFrame:CGRectMake(self.background.frame.origin.x, self.background.frame.origin.y, self.background.frame.size.width, self.time.frame.origin.y + self.time.frame.size.height)];
    
    
    //시간 계산
    long long timeStamp = [[contentDic objectForKey:@"created"] longLongValue];
    NSTimeInterval timeInterval = (double)(timeStamp/1000);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [time setText:[self calculateDate:date]];
    
    [name setText:[[contentDic objectForKey:@"writer"] objectForKey:@"name"]];
    [content setText:[contentDic objectForKey:@"content"]];
    [profileImage setClipsToBounds:YES];
    [profileImage setImageWithURL:[NSURL URLWithString:[[contentDic objectForKey:@"writer"] objectForKey:@"picture"]] placeholderImage:nil];
    
    
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.background.bounds];
//    self.background.layer.masksToBounds = NO;
//    self.background.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//    self.background.layer.shadowOpacity = 1.0;
//    self.background.layer.shadowRadius = 1.5;
//    self.background.layer.shadowOffset = CGSizeMake(0.0, 0.0);
//    self.background.layer.shadowPath = shadowPath.CGPath;
//    self.background.layer.shouldRasterize = YES;
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
@end
