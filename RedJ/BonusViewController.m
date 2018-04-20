//
//  BonusViewController.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/20.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BonusViewController.h"
#import "UserBonus.h"

@interface BonusViewController ()

@end

@implementation BonusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)receiveButtonAction:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@"正在领取"];
    [UserBonus receiveBonus:self.bonus success:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [SVProgressHUD showWithStatus:@"领取成功"];
                [SVProgressHUD dismissWithDelay:.5 completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                [SVProgressHUD showWithStatus:@"领取失败"];
                [SVProgressHUD dismissWithDelay:.5 completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        });
    }];
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
