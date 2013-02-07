//
//  JoinController.m
//  bodybook
//
//  Created by gyuchan jeon on 12. 11. 2..
//  Copyright (c) 2012년 gyuchan-jeon. All rights reserved.
//

#import "JoinController.h"

#import <QuartzCore/QuartzCore.h>
#import <baas.io/Baas.h>

@interface JoinController ()

@end

@implementation JoinController

@synthesize userName, name, email, password, passwordRepeat, scrollView, cancelButton, joinButton;;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    joinButton.layer.cornerRadius = 6;
    joinButton.clipsToBounds = YES;
    
    cancelButton.layer.cornerRadius = 6;
    cancelButton.clipsToBounds = YES;
    
    password.secureTextEntry = YES;
    passwordRepeat.secureTextEntry = YES;
    
    [self.userName setReturnKeyType:UIReturnKeyNext];
    [self.name setReturnKeyType:UIReturnKeyNext];
    [self.email setReturnKeyType:UIReturnKeyNext];
    [self.password setReturnKeyType:UIReturnKeyNext];
    [self.passwordRepeat setReturnKeyType:UIReturnKeyGo];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validateEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(IBAction)cancelTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)joinTouched:(id)sender{
    [self join];
}

-(void)join{
    if(![self validateEmail:[email text]]) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"이메일 확인"]
                              message:[NSString stringWithFormat:@"이메일 입력이 잘못되었습니다"]
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        
        if([password.text isEqualToString:passwordRepeat.text]&&(![password.text isEqualToString:@""])) {
            [BaasioUser signUpInBackground:userName.text
                                  password:password.text
                                      name:name.text
                                     email:email.text
                              successBlock:^(void) {
                                  NSLog(@"회원가입 완료");
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }
                              failureBlock:^(NSError *error) {
                                  NSLog(@"fail : %@", error.localizedDescription);
                              }];
        } else {
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"비밀번호 확인"]
                                  message:[NSString stringWithFormat:@"비밀번호 올바르게 입력하세요"]
                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction) hideKeyboard : (id) sender {
    [userName resignFirstResponder];
    [name resignFirstResponder];
    [email resignFirstResponder];
    [password resignFirstResponder];
    [passwordRepeat resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textFieldView {
    currentTextField = textFieldView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFieldView {
    if (textFieldView == self.userName) {
        [self.userName resignFirstResponder];
        [self.name becomeFirstResponder];
    } else if (textFieldView == self.name) {
        [self.name resignFirstResponder];
        [self.email becomeFirstResponder];
    } else if (textFieldView == self.email) {
        [self.email resignFirstResponder];
        [self.passwordRepeat becomeFirstResponder];
        [self.password becomeFirstResponder];
    } else if (textFieldView == self.password) {
        //[self.password resignFirstResponder];
        [self.passwordRepeat becomeFirstResponder];
    } else if (textFieldView == self.passwordRepeat) {
        [self.passwordRepeat resignFirstResponder];
        [self join];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textFieldView {
    [textFieldView resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *) notification {
    if (keyboardIsShown) return;
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= keyboardRect.size.height;
    scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [currentTextField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    keyboardIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *) notification {
    NSDictionary* info = [notification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += keyboardRect.size.height;
    scrollView.frame = viewFrame;
    
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    keyboardIsShown = NO;
}


@end
