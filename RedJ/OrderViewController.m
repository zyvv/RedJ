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
@property (weak, nonatomic) IBOutlet UILabel *guestLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letOrderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeOrderSegment;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (nonatomic, strong) Order *order;
@property (nonatomic, assign) OrderType orderType;
@property (nonatomic, strong) Account *account;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ - %@", _match.guestTeam, _match.homeTeam];
    self.sureButton.enabled = NO;
    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    AVQuery *userQuery = [AVQuery queryWithClassName:@"Order"];
    [userQuery whereKey:@"orderUserName" equalTo:[AVUser currentUser].username];
    AVQuery *orderQuery = [AVQuery queryWithClassName:@"Order"];
    [orderQuery whereKey:@"matchId" equalTo:_match.thirdId];
    AVQuery *query = [AVQuery andQueryWithSubqueries:[NSArray arrayWithObjects:userQuery,orderQuery,nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (results.count > 0) {
                AVObject *orderObj = results.lastObject;
                NSMutableDictionary *orderDict = [orderObj dictionaryForObject];
                Order *order = [Order yy_modelWithJSON:orderDict];
                self.order = order;
                [self layoutWithOrder:order];
            } else {
                self.sureButton.enabled = YES;
            }
        });
    }];
    
    AVQuery *accountQuery = [AVQuery queryWithClassName:@"Account"];
    [accountQuery whereKey:@"username" equalTo:[AVUser currentUser].username];
    [accountQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (results.count > 0) {
                AVObject *accountObj = results.lastObject;
                NSMutableDictionary *accountDict = [accountObj dictionaryForObject];
                Account *account = [Account yy_modelWithJSON:accountDict];
                self.account = account;
            }
        });
    }];

    _guestLabel.text = [NSString stringWithFormat:@"(客)%@",  _match.guestTeam];
    _homeLabel.text = [NSString stringWithFormat:@"(主)%@",  _match.homeTeam];
    float handicapValue = _match.matchOdds.asiaLet.bet365.handicapValue;
    [_letSegment setTitle:[NSString stringWithFormat:@"主队让%.1f", handicapValue] forSegmentAtIndex:0];

    [_letSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.leftOdds] forSegmentAtIndex:1];
    [_letSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.rightOdds] forSegmentAtIndex:2];
    
    [_sizeSegment setTitle:[NSString stringWithFormat:@"大小分%.1f", _match.matchOdds.asiaSize.bet365.handicapValue] forSegmentAtIndex:0];
    [_sizeSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.leftOdds] forSegmentAtIndex:1];
    [_sizeSegment setTitle:[NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.rightOdds] forSegmentAtIndex:2];
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

- (void)layoutWithOrder:(Order *)order {
    
    if (order.letBetAmount > 0) {
        _letSegment.selectedSegmentIndex = order.betGuest ? 1 : 2;
        _letOrderSegment.selectedSegmentIndex = order.letBetAmount / 10;
        _letSegment.enabled = _letOrderSegment.enabled = NO;
        self.orderType = OrderLet;
        self.sureButton.enabled = YES;
    }
    if (order.sizeBetAmount > 0) {
        _sizeSegment.selectedSegmentIndex = order.betBig ? 1 : 2;
        _sizeOrderSegment.selectedSegmentIndex = order.sizeBetAmount / 10;
        _sizeSegment.enabled = _sizeOrderSegment.enabled = NO;
        self.orderType = OrderSize;
        self.sureButton.enabled = YES;
    }
    
    if (order.letBetAmount > 0 && order.sizeBetAmount > 0) {
        self.sureButton.enabled = NO;
        self.orderType = OrderAll;
        [self.sureButton setTitle:@"已投注" forState:UIControlStateNormal];
        
    }
}

- (IBAction)sureButtonAction:(UIButton *)sender {

    AVObject *orderObj;
    if (self.order.objectId) {
        orderObj = [AVObject objectWithClassName:@"Order" objectId:self.order.objectId];
    } else {
        orderObj = [[AVObject alloc] initWithClassName:@"Order"];
    }
    [orderObj setObject:_match.thirdId forKey:@"matchId"];
    
    BOOL isOrder = NO;
    
    if (_letSegment.selectedSegmentIndex != 0 && _letOrderSegment.selectedSegmentIndex != 0) {
        [orderObj setObject:@(_match.matchOdds.asiaLet.bet365.handicapValue) forKey:@"letValue"]; // 主队让分
        [orderObj setObject:[_letSegment titleForSegmentAtIndex:_letSegment.selectedSegmentIndex] forKey:@"letOdds"]; // 让分赔率
        [orderObj setObject:[_letOrderSegment titleForSegmentAtIndex:_letOrderSegment.selectedSegmentIndex] forKey:@"letBetAmount"]; // 让分下注金额
        [orderObj setObject:@(_letSegment.selectedSegmentIndex == 1 ? YES : NO) forKey:@"betGuest"]; // 投注的是否是客队
        isOrder = YES;
    }
    if (_sizeSegment.selectedSegmentIndex != 0 && _sizeOrderSegment.selectedSegmentIndex != 0) {
        [orderObj setObject:@(_match.matchOdds.asiaSize.bet365.handicapValue) forKey:@"sizeValue"]; // 大小分数值
        
        [orderObj setObject:[_sizeSegment titleForSegmentAtIndex:_sizeSegment.selectedSegmentIndex] forKey:@"sizeOdds"]; // 大小分赔率
        
        [orderObj setObject:[_sizeOrderSegment titleForSegmentAtIndex:_sizeOrderSegment.selectedSegmentIndex] forKey:@"sizeBetAmount"]; // 大小分下注金额
        [orderObj setObject:@(_sizeSegment.selectedSegmentIndex == 1 ? YES : NO) forKey:@"betBig"]; // 投注的是否是大分
        isOrder = YES;
    }
    if (isOrder) {
        AVObject *userOrderMapTom= [[AVObject alloc] initWithClassName:@"UserOrder"];// 用户投注
        [userOrderMapTom setObject:orderObj forKey:@"order"];
        [userOrderMapTom setObject:[AVUser currentUser] forKey:@"user"];
        [orderObj setObject:@(NO) forKey:@"settle"]; // 是否结算
        [orderObj setObject:@(0) forKey:@"earnings"]; // 此单收益
        [orderObj setObject:@(-1) forKey:@"status"]; // -1未结算 0黑 1红
        [orderObj setObject:[NSDate date] forKey:@"orderDate"]; // 下单日期
        [orderObj setObject:_match.date forKey:@"gameDate"]; // 比赛日期
        [orderObj setObject:nil forKey:@"settleDate"]; // 结算日期
        [orderObj setObject:[AVUser currentUser].username forKey:@"orderUserName"]; // 下注者昵称
        
        float orderTotalAmount = 0;
        if (self.orderType == OrderNone) {
            orderTotalAmount = [[_letOrderSegment titleForSegmentAtIndex:_letOrderSegment.selectedSegmentIndex] floatValue] + [[_sizeOrderSegment titleForSegmentAtIndex:_sizeOrderSegment.selectedSegmentIndex] floatValue];
        }
        if (self.orderType == OrderLet) {
            orderTotalAmount = _sizeOrderSegment.selectedSegmentIndex * 10;
        }
        if (self.orderType == OrderSize) {
            orderTotalAmount = _letOrderSegment.selectedSegmentIndex * 10;
        }
        if (self.account.balance < orderTotalAmount) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"余额不足";
            [hud hideAnimated:YES afterDelay:.5];
            return;
        }
        
        // 更新账户
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AVObject *account = [AVObject objectWithClassName:@"Account" objectId:self.account.objectId];
        [account setObject:@(self.account.balance - orderTotalAmount) forKey:@"balance"];
        [account saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            // 下注
            [userOrderMapTom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }];
        }];

    }
    
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
