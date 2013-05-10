//
//  ProfileInfoCell.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 23..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "ProfileInfoCell.h"
#import "UIImage+Utilities.h"
#import "UIImage+Resize.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <baas.io/Baas.h>

#define PROFILEBIGIMAGE_HEIGHT 175.0f
#define IMAGE_WIDTH 400.0f
#define IMAGE_HEIGHT 400.0f

@implementation ProfileInfoCell

@synthesize profileImage, profileBigImage, userNameLabel, profileImageBackground, profileImageChangeButton,nameLabel,viewController,followingCount,followersCount,friendCountView;

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

- (void)initCustomCell:(NSDictionary*)contentDic{
    userInfo = contentDic;
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
    [query setWheres:[NSString stringWithFormat:@"username = '%@'",[[BaasioUser currentUser] objectForKey:@"username"]]];
    [query queryInBackground:^(NSArray *array) {
        NSMutableArray *postUser = [NSMutableArray arrayWithArray:array];
        NSDictionary *userProfileInfo = [[NSDictionary alloc]init];
        userProfileInfo = [postUser objectAtIndex:0];
        [profileBigImage setImageWithURL:[NSURL URLWithString:[userProfileInfo objectForKey:@"picture"]] placeholderImage:nil];
        [profileImage setImageWithURL:[NSURL URLWithString:[userProfileInfo objectForKey:@"picture"]] placeholderImage:nil];
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
    [userNameLabel setText:[[BaasioUser currentUser] objectForKey:@"name"]];
    
    [self.profileBigImage setClipsToBounds:YES];
    [self.profileBigImage setFrame:CGRectMake(self.profileBigImage.frame.origin.x, self.profileBigImage.frame.origin.y, self.profileBigImage.frame.size.width, PROFILEBIGIMAGE_HEIGHT)];
    
    [self.profileImage setClipsToBounds:YES];
    [self.profileImage setFrame:CGRectMake(self.profileImage.frame.origin.x, self.profileImage.frame.origin.y, 90, 90)];
    
    [self.profileImageChangeButton setFrame:CGRectMake(self.profileImageChangeButton.frame.origin.x, self.profileImageChangeButton.frame.origin.y, 90, 90)];
    
    [self.profileImageBackground setFrame:CGRectMake(self.profileImageBackground.frame.origin.x, self.profileImageBackground.frame.origin.y, 100, 100)];
    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.profileImageBackground.bounds];
    self.profileImageBackground.layer.masksToBounds = NO;
    self.profileImageBackground.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.profileImageBackground.layer.shadowOpacity = 1.0;
    self.profileImageBackground.layer.shadowRadius = 1.5;
    self.profileImageBackground.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.profileImageBackground.layer.shadowPath = shadowPath.CGPath;
    self.profileImageBackground.layer.shouldRasterize = YES;
    
    [self.userNameLabel setFrame:CGRectMake(self.userNameLabel.frame.origin.x, self.userNameLabel.frame.origin.y, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height)];
    

    BaasioQuery *query1 = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/followers",[[BaasioUser currentUser]objectForKey:@"username"]]];
    [query1 setLimit:999];
    [query1 queryInBackground:^(NSArray *array) {
        NSMutableArray *friendArray = [[NSMutableArray alloc]initWithArray:array];
        [followersCount setText:[NSString stringWithFormat:@"%d",[friendArray count]]];
        [followersCount setBackgroundColor:[UIColor clearColor]];
        [followersCount setShadowColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
        [followersCount setShadowOffset:CGSizeMake(1, 1)];
        //[followersCount setAlpha:0.0];
    }
                 failureBlock:^(NSError *error) {
                     NSLog(@"팔로워 친구목록 불러오기 실패 : %@", error.localizedDescription);
                 }];
    
    BaasioQuery *query2 = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/following",[[BaasioUser currentUser]objectForKey:@"username"]]];
    [query2 setLimit:999];
    [query2 queryInBackground:^(NSArray *array) {
        NSMutableArray *friendArray = [[NSMutableArray alloc]initWithArray:array];
        [followingCount setText:[NSString stringWithFormat:@"%d",[friendArray count]]];
        [followingCount setBackgroundColor:[UIColor clearColor]];
        [followingCount setShadowColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7]];
        [followingCount setShadowOffset:CGSizeMake(1, 1)];
        //[followingCount setAlpha:0.0];
    }
                 failureBlock:^(NSError *error) {
                     NSLog(@"팔로잉 친구목록 불러오기 실패 : %@", error.localizedDescription);
                 }];
    
    UIBezierPath *shadowPath2 = [UIBezierPath bezierPathWithRect:friendCountView.bounds];
    friendCountView.layer.masksToBounds = NO;
    friendCountView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    friendCountView.layer.shadowOpacity = 1.0;
    friendCountView.layer.shadowRadius = 1.5;
    friendCountView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    friendCountView.layer.shadowPath = shadowPath2.CGPath;
    friendCountView.layer.shouldRasterize = YES;
}

- (IBAction)profileImageChange:(id)sender{
    NSLog(@"imageChange버튼");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSLog(@"이미지가 선택되었음");
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [[UIImage alloc]init];
    resizedImage = [croppedImage resizedImageWithMaximumSize:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT)];

    NSData *contentImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
    BaasioFile *file = [[BaasioFile alloc] init];
    file.data = contentImageData;
    file.filename = @"ProfileImage.jpg";
    file.contentType = @"image/jpeg";
    [file setObject:[[BaasioUser currentUser]objectForKey:@"username"] forKey:@"writer"];
    [file fileUploadInBackground:^(BaasioFile *file) {
        NSLog(@"프로필사진 업로드 성공 : %@", file);
        
        BaasioUser *user = [BaasioUser currentUser];
        //user.username = [[BaasioUser currentUser]objectForKey:@"username"];
        [user setObject:[NSString stringWithFormat:@"https://blob.baas.io/gyuchan/bodybook/files/%@",file.uuid] forKey:@"picture"];
        [user updateInBackground:^(BaasioUser *user) {
                            [picker dismissViewControllerAnimated:YES completion:nil];
                        }
                        failureBlock:^(NSError *error) {
                            NSLog(@"error : %@", error.localizedDescription);
                        }];
    }
    failureBlock:^(NSError *error) {
        NSLog(@"파일 올리기 에러 : %@", error.localizedDescription);
    }
    progressBlock:^(float progress) {
       NSLog(@"progress : %f", progress);
    }];
    
}


@end
