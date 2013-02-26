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
}

@property (nonatomic, retain) IBOutlet UIButton *closeTextField;
@property (nonatomic, retain) IBOutlet UITextField *friendTextField;

@end
