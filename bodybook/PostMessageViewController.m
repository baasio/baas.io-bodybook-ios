//
//  PostMessageViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "PostMessageViewController.h"
#import "UIImage+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <baas.io/Baas.h>

#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@interface PostMessageViewController ()

@end

@implementation PostMessageViewController

@synthesize messageTextField, profileImage, imageAddButton, postButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)flag {
    [super viewWillAppear:flag];
    [messageTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    step = 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    step = 1;
    imageSelected = 0;
    dictionary = [[NSMutableDictionary alloc]init];
    _uploadFileList = [NSMutableArray array];
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
    [query setWheres:[NSString stringWithFormat:@"username = '%@'",[[BaasioUser currentUser] objectForKey:@"username"]]];
    [query queryInBackground:^(NSArray *array) {
        NSMutableArray *postUser = [NSMutableArray arrayWithArray:array];
        NSDictionary *userProfileInfo = [[NSDictionary alloc]init];
        userProfileInfo = [postUser objectAtIndex:0];
        [profileImage setImageWithURL:[NSURL URLWithString:[userProfileInfo objectForKey:@"picture"]] placeholderImage:nil];
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//이미지 추가 관련 소스
-(IBAction)imageAddTouched:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    //    inputProfileImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    [picker dismissModalViewControllerAnimated:YES];
    //imagePostThread = [[NSThread alloc]initWithTarget:self selector:@selector(imagePostFunction) object:nil];
    
    imageSelected = 1;

    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [[UIImage alloc]init];
    if(croppedImage.size.width > IMAGE_WIDTH){
        if(croppedImage.size.height > IMAGE_HEIGHT){
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
        }else{
            resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, originalImage.size.height) imageOrientation:originalImage.imageOrientation];
        }
    }else{
        //resizedImage = [croppedImage resizedImage:CGSizeMake(croppedImage.size.width, croppedImage.size.height) imageOrientation:originalImage.imageOrientation];
        resizedImage = croppedImage;
    }
    
    [imageAddButton setBackgroundImage:resizedImage forState:UIControlStateNormal];
    
    NSURL *url = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:url
                  resultBlock:^(ALAsset *asset){
                      ALAssetRepresentation *rep = [asset defaultRepresentation];
                      dictionary = [NSMutableDictionary dictionaryWithDictionary:info];
                      [dictionary setObject:rep.filename forKey:@"filename"];
                  }
                 failureBlock:^(NSError *err) {
                     NSLog(@"Error: %@",[err localizedDescription]);
                 }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postMessage:(id)sender {
    if (![messageTextField.text isEqualToString:@""]) {
        [postButton setEnabled:NO];
        if(imageSelected == 1){
            //이미지를 선택했을 경우.
            int index = [_uploadFileList count];
            [_uploadFileList insertObject:dictionary atIndex:index];
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            UIImage *contentImage = [imageAddButton backgroundImageForState:UIControlStateNormal];
            NSData *contentImageData = UIImageJPEGRepresentation(contentImage, 1.0);
            
            BaasioFile *file = [[BaasioFile alloc] init];
            file.data = contentImageData;
            file.filename = @"사진.jpeg";
            file.contentType = @"image/jpeg";
            [file setObject:[[BaasioUser currentUser]objectForKey:@"username"] forKey:@"writer"];
            [file fileUploadInBackground:^(BaasioFile *file) {
                NSLog(@"사진올리기 성공 : %@", file.uuid);
                BaasioEntity *entity = [BaasioEntity entitytWithName:@"feed"];
                [entity setObject:[[BaasioUser currentUser] objectForKey:@"username"] forKey:@"username"];
                [entity setObject:[[BaasioUser currentUser] objectForKey:@"name"] forKey:@"nameID"];
                [entity setObject:[[BaasioUser currentUser] objectForKey:@"picture"] forKey:@"picture"];
                [entity setObject:[messageTextField text] forKey:@"content"];
                [entity setObject:@"0" forKey:@"like"];
                [entity setObject:@"0" forKey:@"bad"];
                [entity setObject:[NSString stringWithFormat:@"https://blob.baas.io/gyuchan/bodybook/files/%@",file.uuid] forKey:@"contentImagePath"];
                
                [entity saveInBackground:^(BaasioEntity *entity) {
                    NSLog(@"포스팅 성공 : %@", entity.description);
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                            failureBlock:^(NSError *error) {
                                NSLog(@"fail : %@", error.localizedDescription);
                            }];
            }
                            failureBlock:^(NSError *error) {
                                NSLog(@"사진올리기 실패 : %@", error.localizedDescription);
                            }
                           progressBlock:^(float progress) {
                               NSLog(@"사진 올리는 중 : %f", progress);
                           }];
            
 
        }else{
            //이미지를 선택하지 않았을 경우.
            BaasioEntity *entity = [BaasioEntity entitytWithName:@"feed"];
            [entity setObject:[[BaasioUser currentUser] objectForKey:@"username"] forKey:@"username"];
            [entity setObject:[[BaasioUser currentUser] objectForKey:@"name"] forKey:@"nameID"];
            [entity setObject:[messageTextField text] forKey:@"content"];
            [entity setObject:@"0" forKey:@"like"];
            [entity setObject:@"0" forKey:@"bad"];
            [entity setObject:@"-" forKey:@"contentImagePath"];
            
            [entity saveInBackground:^(BaasioEntity *entity) {
                NSLog(@"포스팅 성공 : %@", entity.description);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
                        failureBlock:^(NSError *error) {
                            NSLog(@"fail : %@", error.localizedDescription);
                        }];
        }
        [dictionary setValue:nil forKey:@"uploadedInfo"];

    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"업로드 실패"
                              message:@"다시 시도하세요"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)closeMessage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
