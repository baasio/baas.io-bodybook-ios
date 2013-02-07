//
//  ViewController.h
//  bodybook
//
//  Created by gyuchan jeon on 13. 2. 4..
//  Copyright (c) 2013년 gyuchan jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    UIImageView *bodybookTitle;
    UIImageView *textFileBackground;
    UIButton *loginButton;
    UIButton *joinButton;
    UITextField *userName;
    UITextField *password;
    
    BOOL keyboardIsShown;
    UITextField *currentTextField;
    UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UIImageView *bodybookTitle;
@property (nonatomic, retain) IBOutlet UIImageView *textFileBackground;
@property (nonatomic, retain) IBOutlet UIButton *loginButton,*joinButton;
@property (nonatomic, nonatomic) IBOutlet UITextField *userName;
@property (nonatomic, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

-(IBAction)loginTouched:(id)sender;
-(IBAction)joinTouched:(id)sender;
@end
