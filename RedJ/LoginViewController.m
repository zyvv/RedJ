//
//  LoginViewController.m
//  RedJ
//
//  Created by vi~ on 2018/4/13.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "LoginViewController.h"
#import "Account.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registAndLoginButtonAction:(UIButton *)sender {

//    self.usernameTextField.text = @"LJYH";
//    self.passwordTextField.text = @"1234567890";
    if (self.usernameTextField.text.length <= 0 || self.usernameTextField.text.length > 8) {
        return;
    }
    if (self.passwordTextField.text.length <= 0 || self.passwordTextField.text.length > 16) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"正在登录...";
    [AVUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(AVUser * _Nullable user, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                hud.mode = MBProgressHUDModeText;
                hud.label.text = error.localizedDescription;
                [hud hideAnimated:YES afterDelay:.25];
            } else {
//                AVQuery *accountQuery = [AVQuery queryWithClassName:@"Account"];
//                [accountQuery whereKey:@"username" equalTo:[AVUser currentUser].username];
//                [accountQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//                    if (objects.count > 0) {
//                        AVObject *orderObj = objects.lastObject;
//                        [orderObj setObject:[AVUser currentUser] forKey:@"dependent"];
//                        [orderObj saveInBackground];
////                        NSMutableDictionary *orderDict = [orderObj dictionaryForObject];
//                    }
//                }];
//                AVObject *account = [AVObject objectWithClassName:@"Account"];
//                [account setObject:@(1000) forKey:@"totalAccount"];
//                [account setObject:@(1000) forKey:@"balance"];
//                [account setObject:[AVUser currentUser].username forKey:@"username"];
//                 AVObject *userOrderMapTom= [[AVObject alloc] initWithClassName:@"UserAccount"];
//                [userOrderMapTom setObject:account forKey:@"account"];
//                [userOrderMapTom setObject:[AVUser currentUser] forKey:@"user"];
//                [userOrderMapTom saveInBackground];

                [hud hideAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }

        });
    }];

    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
