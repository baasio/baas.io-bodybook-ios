//
//  ProfileInfoCell.m
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 23..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "ProfileInfoCell.h"
#import "UIImage+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <baas.io/Baas.h>

#define PROFILEBIGIMAGE_HEIGHT 175.0f
#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@implementation ProfileInfoCell

@synthesize profileImage, profileBigImage, userNameLabel, profileImageBackground, profileImageChangeButton, photoButtonImage,nameLabel,viewController;

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
    
    [self.photoButtonImage setFrame:CGRectMake(self.profileImage.frame.origin.x, self.profileImage.frame.origin.y, 30, 30)];
    
    [self.profileImage setClipsToBounds:YES];
    [self.profileImage setFrame:CGRectMake(self.profileImage.frame.origin.x, self.profileImage.frame.origin.y, 90, 90)];
    
    [self.profileImageChangeButton setFrame:CGRectMake(self.profileImageChangeButton.frame.origin.x,  PROFILEBIGIMAGE_HEIGHT-50, 90, 90)];
    
    [self.profileImageBackground setFrame:CGRectMake(self.profileImageBackground.frame.origin.x, PROFILEBIGIMAGE_HEIGHT-50, 100, 100)];
    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.profileImageBackground.bounds];
    self.profileImageBackground.layer.masksToBounds = NO;
    self.profileImageBackground.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.profileImageBackground.layer.shadowOpacity = 1.0;
    self.profileImageBackground.layer.shadowRadius = 1.5;
    self.profileImageBackground.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.profileImageBackground.layer.shadowPath = shadowPath.CGPath;
    self.profileImageBackground.layer.shouldRasterize = YES;
    
    [self.userNameLabel setFrame:CGRectMake(self.userNameLabel.frame.origin.x, PROFILEBIGIMAGE_HEIGHT+10, self.userNameLabel.frame.size.width, self.userNameLabel.frame.size.height)];
}

- (IBAction)profileImageChange:(id)sender{
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
    
    if(croppedImage.size.width > 612){
        if(croppedImage.size.height > 612){
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
        }else{
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, croppedImage.size.height) imageOrientation:originalImage.imageOrientation];
        }
    }else{
        resizedImage = croppedImage;
    }
    
    NSData *contentImageData = UIImageJPEGRepresentation(resizedImage, 1.0);
    BaasioFile *file = [[BaasioFile alloc] init];
    file.data = contentImageData;
    file.filename = @"프로필사진.png";
    file.contentType = @"application/json";
    [file setObject:[[BaasioUser currentUser]objectForKey:@"username"] forKey:@"writer"];
    [file fileUploadInBackground:^(BaasioFile *file) {
        NSLog(@"프로필사진 업로드 성공 : %@", file.uuid);
        BaasioEntity *entity = [BaasioEntity entitytWithName:@"SomeBlog"];
        entity.uuid = [[BaasioUser currentUser]objectForKey:@"uuid"];
        [entity setObject:[NSString stringWithFormat:@"https://blob.baas.io/gyuchan/bodybook/files/%@",file.uuid] forKey:@"picture"];
        [entity updateInBackground:^(BaasioEntity *entity) {
            NSLog(@"Entity수정 성공 %@",entity);
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
                      failureBlock:^(NSError *error) {
                          NSLog(@"Entity수정 실패 : %@", error.localizedDescription);
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
