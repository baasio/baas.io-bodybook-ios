//
//  PostMessageViewController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 8..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "PostMessageViewController.h"
#import "UIImage+Utilities.h"
#import "UIImage+Resize.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <baas.io/Baas.h>

#define IMAGE_WIDTH 612.f
#define IMAGE_HEIGHT 612.f

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
    
    UIImage *navBackground =[[UIImage imageNamed:@"navigationBar@2x.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    UINavigationItem *buttonCarrier = [[UINavigationItem alloc]initWithTitle:@"글 올리기"];
    UINavigationBar *naviBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    [naviBar setBackgroundImage:navBackground forBarMetrics:UIBarMetricsDefault];
    
    
    postButton =[[UIButton alloc] init];
    [postButton setBackgroundImage:[UIImage imageNamed:@"button@2x.png"] forState:UIControlStateNormal];
    UILabel *btnText = [[UILabel alloc]init];
    [btnText setText:@"올리기"];
    [btnText setFont:[UIFont boldSystemFontOfSize:13]];
    [btnText setTextColor:[UIColor whiteColor]];
    [btnText setFrame:CGRectMake(0, 0, 50, 30)];
    [btnText setTextAlignment:NSTextAlignmentCenter];
    [btnText setBackgroundColor:[UIColor clearColor]];
    [postButton addSubview:btnText];
    
    postButton.frame = CGRectMake(100, 100, 50, 30);
    UIBarButtonItem *postBarButton =[[UIBarButtonItem alloc] initWithCustomView:postButton];
    [postButton addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btnBack =[[UIButton alloc] init];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"backButton@2x.png"] forState:UIControlStateNormal];
    UILabel *btnText2 = [[UILabel alloc]init];
    [btnText2 setText:@"뒤로"];
    [btnText2 setFont:[UIFont boldSystemFontOfSize:13]];
    [btnText2 setTextColor:[UIColor whiteColor]];
    [btnText2 setFrame:CGRectMake(3, 0, 50, 30)];
    [btnText2 setTextAlignment:NSTextAlignmentCenter];
    [btnText2 setBackgroundColor:[UIColor clearColor]];
    [btnBack addSubview:btnText2];
    
    btnBack.frame = CGRectMake(100, 100, 50, 30);
    UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc] initWithCustomView:btnBack];
    [btnBack addTarget:self action:@selector(closeMessage) forControlEvents:UIControlEventTouchUpInside];

    [buttonCarrier setRightBarButtonItem:postBarButton];
    [buttonCarrier setLeftBarButtonItem:backBarButton];
    
    
    NSArray *barItemArray = [[NSArray alloc]initWithObjects:buttonCarrier,nil];
    [naviBar setItems:barItemArray];
    [self.view addSubview:naviBar];
    
    
    dictionary = [[NSMutableDictionary alloc]init];
    _uploadFileList = [NSMutableArray array];
    BaasioQuery *query = [BaasioQuery queryWithCollection:@"users"];
    [query setWheres:[NSString stringWithFormat:@"username = '%@'",[[BaasioUser currentUser] objectForKey:@"username"]]];
    [query queryInBackground:^(NSArray *array) {
        NSMutableArray *postUser = [NSMutableArray arrayWithArray:array];
        NSDictionary *userProfileInfo = [[NSDictionary alloc]init];
        userProfileInfo = [postUser objectAtIndex:0];
        [profileImage setClipsToBounds:YES];
        [profileImage setImageWithURL:[NSURL URLWithString:[userProfileInfo objectForKey:@"picture"]] placeholderImage:nil];
    }
                failureBlock:^(NSError *error) {
                    NSLog(@"fail : %@", error.localizedDescription);
                }];
    

    
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
    //picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}




-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    //    inputProfileImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    [picker dismissModalViewControllerAnimated:YES];
    //imagePostThread = [[NSThread alloc]initWithTarget:self selector:@selector(imagePostFunction) object:nil];
    
    imageSelected = 1;

    //CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    //UIImage *halfSizeImage = [self resizeImage:originalImage width:originalImage.size.width * 0.5 height:originalImage.size.height * 0.5];
    //cropRect = [originalImage convertCropRect:cropRect];
    //UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [originalImage resizedImageWithMaximumSize:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT)];

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

- (void)postMessage{
    [self loadingViewStart];
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
            file.filename = @"contentImage.jpg";
            file.contentType = @"image/jpeg";
            [file setObject:[[BaasioUser currentUser]objectForKey:@"username"] forKey:@"writer"];
            [file fileUploadInBackground:^(BaasioFile *file) {
                NSLog(@"사진올리기 성공 : %@", file.uuid);
                BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/activities",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
//                [entity setObject:[[BaasioUser currentUser] objectForKey:@"username"] forKey:@"username"];
                
                ///////////////////////////////////꼭 등록되어있어야함////////////////////////////////////////
                [entity setObject:[BaasioUser currentUser] forKey:@"actor"];
                [entity setObject:@"post" forKey:@"verb"];
                /////////////////////////////////////////////////////////////////////////////////////////

                [entity setObject:[[BaasioUser currentUser] objectForKey:@"name"] forKey:@"nameID"];
                [entity setObject:[messageTextField text] forKey:@"content"];
                [entity setObject:@"0" forKey:@"like"];
                [entity setObject:@"0" forKey:@"bad"];
                [entity setObject:[NSString stringWithFormat:@"https://api.baas.io/gyuchan/bodybook/files/%@/data",file.uuid] forKey:@"contentImagePath"];
                
                [entity saveInBackground:^(BaasioEntity *entity) {
                    NSLog(@"포스팅 성공 : %@", entity.description);
                    BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/followers",[[BaasioUser currentUser]objectForKey:@"username"]]];
                    //limit이 걸리나? 그럼 10개한정이면 10명이상의 친구가 있을 경우는 어쩌지? 답 : next, preview기능이 있다.
                    [query queryInBackground:^(NSArray *array) {
                        NSMutableArray *friendArray = [[NSMutableArray alloc]initWithArray:array];
                        NSDictionary *friendInfo = [[NSDictionary alloc]init];
                        if(friendArray.count>=1){
                            BaasioPush *push = [[BaasioPush alloc] init];
                            BaasioMessage *message = [[BaasioMessage alloc]init];
                            message.alert = [NSString stringWithFormat:@"%@님이 글을 올렸습니다",[[BaasioUser currentUser] objectForKey:@"name"]];
                            message.target = @"tag";
                            NSMutableArray *messageTO = [[NSMutableArray alloc]init];
                            for(int i=0;i<friendArray.count;i++){
                                friendInfo = [friendArray objectAtIndex:i];
                                [messageTO addObject:[NSString stringWithFormat:@"t%@",[friendInfo objectForKey:@"username"]]];
                            }
                            message.to = messageTO;
                            NSLog(@"message.to.description:%@",message.to.description);
                            [push sendPushInBackground:message
                                          successBlock:^(void) {
                                              NSLog(@"푸시보내기 성공");
                                          }
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"푸시보내기 실패 : %@", error.localizedDescription);
                                          }];
                        }
                    }
                                failureBlock:^(NSError *error) {
                                    NSLog(@"친구목록 불러오기 실패 : %@", error.localizedDescription);
                                }];
                    [postButton setEnabled:YES];
                    [self loadingViewEnd];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                            failureBlock:^(NSError *error) {
                                [self loadingViewEnd];
                                [postButton setEnabled:YES];
                                NSLog(@"fail : %@", error.localizedDescription);
                            }];
            }
                            failureBlock:^(NSError *error) {
                                [self loadingViewEnd];
                                [postButton setEnabled:YES];
                                NSLog(@"사진올리기 실패 : %@", error.localizedDescription);
                            }
                           progressBlock:^(float progress) {
                               NSLog(@"사진 올리는 중 : %f", progress);
                           }];
            
 
        }else{
            //이미지를 선택하지 않았을 경우.
            BaasioEntity *entity = [BaasioEntity entitytWithName:[NSString stringWithFormat:@"users/%@/activities",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
//            [entity setObject:[[BaasioUser currentUser] objectForKey:@"username"] forKey:@"username"];

            ///////////////////////////////////꼭 등록되어있어야함////////////////////////////////////////
            [entity setObject:[BaasioUser currentUser] forKey:@"actor"];
            [entity setObject:@"post" forKey:@"verb"];
            /////////////////////////////////////////////////////////////////////////////////////////
            
            [entity setObject:[[BaasioUser currentUser] objectForKey:@"name"] forKey:@"nameID"];
            [entity setObject:[messageTextField text] forKey:@"content"];
            [entity setObject:@"0" forKey:@"like"];
            [entity setObject:@"0" forKey:@"bad"];
            [entity setObject:@"-" forKey:@"contentImagePath"];
            
            [entity saveInBackground:^(BaasioEntity *entity) {
                NSLog(@"포스팅 성공 : %@", entity.description);
                BaasioQuery *query = [BaasioQuery queryWithCollection:[NSString stringWithFormat:@"users/%@/followers",[[BaasioUser currentUser]objectForKey:@"uuid"]]];
                //limit이 걸리나? 그럼 10개한정이면 10명이상의 친구가 있을 경우는 어쩌지? 답 : next, preview기능이 있다.
                [query queryInBackground:^(NSArray *array) {
                    NSMutableArray *friendArray = [[NSMutableArray alloc]initWithArray:array];
                    NSDictionary *friendInfo = [[NSDictionary alloc]init];
                    NSLog(@"%d",friendArray.count);
                    if(friendArray.count>=1){
                        BaasioPush *push = [[BaasioPush alloc] init];
                        BaasioMessage *message = [[BaasioMessage alloc]init];
                        message.alert = [NSString stringWithFormat:@"%@님이 글을 올렸습니다",[[BaasioUser currentUser] objectForKey:@"name"]];
                        message.target = @"tag";
                        NSMutableArray *messageTO = [[NSMutableArray alloc]init];
                        for(int i=0;i<friendArray.count;i++){
                            friendInfo = [friendArray objectAtIndex:i];
                            [messageTO addObject:[NSString stringWithFormat:@"t%@",[friendInfo objectForKey:@"username"]]];
                        }
                        message.to = messageTO;
                        NSLog(@"message.to.description:%@",message.to.description);
                        [push sendPushInBackground:message
                                      successBlock:^(void) {
                                          NSLog(@"푸시보내기 성공");
                                      }
                                      failureBlock:^(NSError *error) {
                                          NSLog(@"푸시보내기 실패 : %@", error.localizedDescription);
                                      }];
                    }
                }
                            failureBlock:^(NSError *error) {
                                NSLog(@"친구목록 불러오기 실패 : %@", error.localizedDescription);
                            }];
                [self loadingViewEnd];
                [postButton setEnabled:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
                        failureBlock:^(NSError *error) {
                            [self loadingViewEnd];
                            [postButton setEnabled:YES];
                            NSLog(@"fail : %@", error.localizedDescription);
                        }];
        }
        [dictionary setValue:nil forKey:@"uploadedInfo"];

    } else {
        [self loadingViewEnd];
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"업로드 실패"
                              message:@"다시 시도하세요"
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)loadingViewStart{
    indecatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 115.0f, 35.0f)];
    //indecatorView.backgroundColor = [UIColor colorWithRed:245.0f green:245.0f blue:245.0f alpha:1.0f];
    indecatorView.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.9f];;
    indecatorView.layer.masksToBounds = YES;
    indecatorView.layer.cornerRadius = 5.0f;
    indecatorView.alpha = 0;
    
    [self.view addSubview:indecatorView];
    
    //indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(10.0f, 8.0f, 20.0f, 20.0f);
    activityIndicator.hidesWhenStopped = YES;
    
    [indecatorView addSubview:activityIndicator];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45.0f, 11.0f, 100.0f, 15.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"로딩중입니다";
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = [UIColor whiteColor];
    
    [indecatorView addSubview:label];
    indecatorView.center = self.view.center;
    indecatorView.transform = CGAffineTransformMakeScale(1.2f,1.2f);
    
    //애니메이션 구현
    [UIProgressView beginAnimations:nil context:nil];
    [UIProgressView setAnimationDuration:0.5];
    [UIProgressView setAnimationDelay:0.3];
    indecatorView.transform = CGAffineTransformMakeScale(1.0f,1.0f);
    indecatorView.alpha = 1;
    [UIProgressView commitAnimations];
    [activityIndicator startAnimating];
}

-(void)loadingViewEnd{
    //애니메이션 구현
    [UIProgressView beginAnimations:nil context:nil];
    [UIProgressView setAnimationDuration:0.5];
    indecatorView.transform = CGAffineTransformMakeScale(1.2f,1.2f);
    indecatorView.alpha = 0;
    [UIProgressView commitAnimations];
    [activityIndicator startAnimating];
}

- (void)closeMessage{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
