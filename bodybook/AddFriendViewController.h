//
//  AddFriendViewController.h
//  bodybook
//
//  Created by Jeon Gyuchan on 12. 11. 18..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendViewController : UIViewController <UITextFieldDelegate>{
    UIButton *addFriend;
    UIImageView *check;
    UILabel *checkText;
}

@property (nonatomic, retain) IBOutlet UIButton *addFriend, *closeTextField;
@property (nonatomic, retain) IBOutlet UITextField *friendTextField;
@property (nonatomic, retain) IBOutlet UIImageView *check;
@property (nonatomic, retain) IBOutlet UILabel *checkText;

@end
