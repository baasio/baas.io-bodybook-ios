//
//  JoinController.h
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 2..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    BOOL keyboardIsShown;
    UITextField *currentTextField;
    
    UIScrollView *scrollView;
}

@property (retain, nonatomic) IBOutlet UIButton *cancelButton, *joinButton;
@property (retain, nonatomic) IBOutlet UITextField *userName, *name, *email, *password;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


@end
