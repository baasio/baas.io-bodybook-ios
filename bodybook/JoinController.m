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

@interface JoinController (){
    UITableView *_tableView;
}

@end

@implementation JoinController

@synthesize userName, name, email, password, scrollView, cancelButton, joinButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationBar* navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"가입하기"];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"취소" style:UIBarButtonItemStyleBordered target:nil action:@selector(cancelTouched)];
        navigationItem.leftBarButtonItem = buttonItem;
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        [self.view addSubview:navigationBar];
        
        CGRect frame = CGRectMake(0, 44, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.scrollEnabled = NO;
        _tableView.allowsSelection = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:_tableView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [scrollView setScrollEnabled:YES];
    CGSize scrollableSize = CGSizeMake(320, self.view.frame.size.height);
    [scrollView setContentSize:scrollableSize];
//    joinButton.layer.cornerRadius = 6;
//    joinButton.clipsToBounds = YES;
//    
//    cancelButton.layer.cornerRadius = 6;
//    cancelButton.clipsToBounds = YES;
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

-(void)cancelTouched{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)join{
    if(![self validateEmail:[email text]]) {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"이메일 확인"]
                              message:[NSString stringWithFormat:@"이메일 입력이 잘못되었습니다"]
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        
        if(![password.text isEqualToString:@""]){
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
                                  message:[NSString stringWithFormat:@"비밀번호를 입력하세요"]
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
}

- (BOOL)checkButtonEnable
{
    if (![userName.text isEqualToString:@""] && ![name.text isEqualToString:@""] && ![email.text isEqualToString:@""] && ![password.text isEqualToString:@""]){
        joinButton.enabled = YES;
    }else{
        joinButton.enabled = NO;
    }
    return joinButton.enabled;
}

- (void)textFieldDidBeginEditing:(UITextField *)textFieldView{
    currentTextField = textFieldView;
    //[self checkButtonEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textFieldView{
    [textFieldView resignFirstResponder];
    //[self checkButtonEnable];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:
(NSRange)range replacementString:(NSString *)string
{
    [self checkButtonEnable];
    return true;
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
        [self.password becomeFirstResponder];
    } else if (textFieldView == self.password) {
        [self.password resignFirstResponder];
        [self join];
    }
    return YES;
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


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 300;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
    footerView.backgroundColor = [UIColor clearColor];
    
    joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    joinButton.frame = CGRectMake(10, 10, 300, 44);
    [joinButton setTitle:@"가입하기" forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    joinButton.enabled = false;
    joinButton.tag = 11;
    [footerView addSubview:joinButton];
    
    UILabel *joinInfo = [[UILabel alloc]init];
    joinInfo.frame = CGRectMake(10, 40, 300, 44);
    joinInfo.font = [UIFont systemFontOfSize:13.];
    joinInfo.text = @"baas.io를 이용한 SNS세계에 동참하세요";
    joinInfo.textColor = [UIColor whiteColor];
    joinInfo.textAlignment = NSTextAlignmentCenter;
    joinInfo.backgroundColor = [UIColor clearColor];
    [footerView addSubview:joinInfo];
    
    return footerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"entityCell";
    
    UITableViewCell *entityCell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (entityCell == nil) {
        entityCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 44)];
        label.backgroundColor = [UIColor clearColor];
        label.tag = 1;
        [entityCell addSubview:label];

        switch (indexPath.row) {
            case 0:
                userName = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 44)];
                userName.delegate = self;
                userName.backgroundColor = [UIColor clearColor];
                userName.tag = 20 + indexPath.row;
                userName.placeholder = @"Username";
                userName.returnKeyType = UIReturnKeyNext;
                userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
                [entityCell addSubview:userName];
                break;
            case 1:
                name = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 44)];
                name.delegate = self;
                name.backgroundColor = [UIColor clearColor];
                name.tag = 20 + indexPath.row;
                name.placeholder = @"전규찬";
                name.returnKeyType = UIReturnKeyNext;
                name.autocapitalizationType = UITextAutocapitalizationTypeNone;
                [entityCell addSubview:name];
                break;
            case 2:
                email = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 44)];
                email.delegate = self;
                email.backgroundColor = [UIColor clearColor];
                email.tag = 20 + indexPath.row;
                email.placeholder = @"email@example.com";
                email.returnKeyType = UIReturnKeyNext;
                email.autocapitalizationType = UITextAutocapitalizationTypeNone;
                [entityCell addSubview:email];
                break;
            case 3:
                password = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 44)];
                password.delegate = self;
                password.backgroundColor = [UIColor clearColor];
                password.tag = 20 + indexPath.row;
                password.placeholder = @"필수입력";
                password.secureTextEntry = YES;
                password.autocapitalizationType = UITextAutocapitalizationTypeNone;
                password.returnKeyType = UIReturnKeyGo;
                [entityCell addSubview:password];
            default:
                break;
        }
    }
    
    UILabel *label = (UILabel*)[entityCell viewWithTag:1];
    UITextField *field = (UITextField*)[entityCell viewWithTag:2 + indexPath.row];
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    switch (indexPath.row){
        case 0:
            label.text = @"아이디";
            break;
        case 1:
            label.text = @"이름";
            break;
        case 2:
            label.text = @"이메일";
            break;
        case 3:
            label.text = @"비밀번호";
            break;
    }
    return entityCell;
}

@end
