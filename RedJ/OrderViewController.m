//
//  OrderViewController.m
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "OrderViewController.h"
#import "Order.h"
#import "Account.h"

typedef enum : NSUInteger {
    OrderNone,
    OrderAll,
    OrderLet,
    OrderSize,
} OrderType;

@interface OrderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *guestLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *guestLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *letVaultLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeValueLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letOrderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeOrderSegment;
@property (weak, nonatomic) IBOutlet UIButton *letButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (nonatomic, assign) OrderType orderType;
@property (nonatomic, strong) Account *account;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    self.title = [NSString stringWithFormat:@"%@ - %@", _match.guestTeam, _match.homeTeam];
    self.letButton.enabled = self.sizeButton.enabled = NO;
    self.letButton.layer.masksToBounds = self.sizeButton.layer.masksToBounds = YES;
    self.letButton.layer.cornerRadius = self.sizeButton.layer.cornerRadius = 5;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVQuery *userQuery = [AVQuery queryWithClassName:@"Bet"];
    [userQuery whereKey:@"orderUserName" equalTo:[AVUser currentUser].username];
    AVQuery *matchQuery = [AVQuery queryWithClassName:@"Bet"];
    [matchQuery whereKey:@"matchId" equalTo:_match.thirdId];
    AVQuery *query = [AVQuery andQueryWithSubqueries:[NSArray arrayWithObjects:userQuery,matchQuery,nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (results.count > 0) {
                if (results.count == 1) {
                    if (!(_match.matchStatus == -1 || (_match.matchStatus != 0 && _match.matchStatus != -1))) {
                        self.sizeButton.enabled = YES;
                        self.letButton.enabled = YES;
                    }
                }
                for (AVObject *obj in results) {
                    NSMutableDictionary *betDict = [obj dictionaryForObject];
                    Bet *bet = [Bet yy_modelWithJSON:betDict];
                    if (bet.isSize) {
                        [self layoutSize:bet];
                    } else {
                        [self layoutLet:bet];
                    }
                }
            } else {
                if (!(_match.matchStatus == -1 || (_match.matchStatus != 0 && _match.matchStatus != -1))) {
                    self.sizeButton.enabled = YES;
                    self.letButton.enabled = YES;
                }
            }
        });
     }];
    
    
    [User currentUserAccount:^(Account *account, NSError *error) {
         self.account = account;
    }];

    [_guestLogoImageView yy_setImageWithURL:_match.guestLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    [_homeLogoImageView yy_setImageWithURL:_match.homeLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    
    _guestLabel.text = [NSString stringWithFormat:@"(客)%@",  _match.guestTeam];
    _homeLabel.text = [NSString stringWithFormat:@"(主)%@",  _match.homeTeam];

    _letVaultLabel.text = [NSString stringWithFormat:@"%.1f", _match.matchOdds.asiaLet.bet365.handicapValue];
    _sizeValueLabel.text = [NSString stringWithFormat:@"%.1f", _match.matchOdds.asiaSize.bet365.handicapValue];
    
    [_letSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.leftOdds] forSegmentAtIndex:0];
    [_letSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.rightOdds] forSegmentAtIndex:1];
    
    [_sizeSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.leftOdds] forSegmentAtIndex:0];
    [_sizeSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.rightOdds] forSegmentAtIndex:1];
    
    if (_match.matchStatus == -1) {
        _letSegment.enabled = _letOrderSegment.enabled = _sizeSegment.enabled = _sizeOrderSegment.enabled = NO;
        _statusLabel.text = @"比赛已结束";
    } else if (_match.matchStatus != 0) {
        _letSegment.enabled = _letOrderSegment.enabled = _sizeSegment.enabled = _sizeOrderSegment.enabled = NO;
        _statusLabel.text = @"比赛正在进行中";
    } else {
        _statusLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAccount:(Account *)account {
    if (_account != account) {
        _account = account;
    }
    self.balanceLabel.text = [NSString stringWithFormat:@"账户余额：%.2f", account.balance];
}

- (void)layoutLet:(Bet *)letBet {
    _letSegment.selectedSegmentIndex = letBet.leftOdds ? 0 : 1;
    _letOrderSegment.selectedSegmentIndex = letBet.betAmount / 10;
    _letSegment.enabled = _letOrderSegment.enabled = NO;
    self.letButton.enabled = NO;
    [self.letButton setTitle:@"已投注" forState:UIControlStateNormal];
}

- (void)layoutSize:(Bet *)sizeBet {
    _sizeSegment.selectedSegmentIndex = sizeBet.leftOdds ? 0 : 1;
    _sizeOrderSegment.selectedSegmentIndex = sizeBet.betAmount / 10;
    _sizeSegment.enabled = _sizeOrderSegment.enabled = NO;
    self.sizeButton.enabled = NO;
    [self.sizeButton setTitle:@"已投注" forState:UIControlStateNormal];
}

- (IBAction)letButtonAction:(UIButton *)sender {
    
    if (_letOrderSegment.selectedSegmentIndex == 0) {
        return;
    }
    
    Bet *letBet = [Bet new];
    letBet.betAmount = _letOrderSegment.selectedSegmentIndex * 10;
    
    if (self.account.balance < letBet.betAmount) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"余额不足";
        [hud hideAnimated:YES afterDelay:.5];
        return;
    }
    
    letBet.orderUserName = [User currentUser].username;
    letBet.isSize = NO;
    letBet.betOdds = [[_letSegment titleForSegmentAtIndex:_sizeSegment.selectedSegmentIndex] floatValue];
    letBet.leftOdds = _letSegment.selectedSegmentIndex == 0 ? YES : NO;
    letBet.matchId = _match.thirdId;
    letBet.matchDate = _match.date;
    
    letBet.settle = NO;
    letBet.earnings = 0;
    letBet.status = -1;
    letBet.match = _match;
    letBet.betDate = [NSDate date];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [letBet bet:self.account betBlock:^(BOOL success, Account *account, NSError *error) {
        if (success) {
            self.account = account;
            [sender setTitle:@"已投注" forState:UIControlStateNormal];
            _letSegment.enabled = _letOrderSegment.enabled = sender.enabled = NO;
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)sizeButtonAction:(UIButton *)sender {
    if (_sizeOrderSegment.selectedSegmentIndex == 0) {
        return;
    }
    
    Bet *sizeBet = [Bet new];
    sizeBet.betAmount = _sizeOrderSegment.selectedSegmentIndex * 10;
    
    if (self.account.balance < sizeBet.betAmount) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"余额不足";
        [hud hideAnimated:YES afterDelay:.5];
        return;
    }
    
    sizeBet.orderUserName = [User currentUser].username;
    sizeBet.isSize = YES;
    sizeBet.betOdds = [[_sizeSegment titleForSegmentAtIndex:_sizeSegment.selectedSegmentIndex] floatValue];
    sizeBet.leftOdds = _sizeSegment.selectedSegmentIndex == 0 ? YES : NO;
    sizeBet.matchId = _match.thirdId;
    
    sizeBet.settle = NO;
    sizeBet.earnings = 0;
    sizeBet.status = -1;
    sizeBet.match = _match;
    sizeBet.betDate = [NSDate date];
    sizeBet.matchDate = _match.date;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [sizeBet bet:self.account betBlock:^(BOOL success, Account *account, NSError *error) {
        if (success) {
            self.account = account;
            [sender setTitle:@"已投注" forState:UIControlStateNormal];
            _sizeSegment.enabled = _sizeOrderSegment.enabled = sender.enabled = NO;
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
