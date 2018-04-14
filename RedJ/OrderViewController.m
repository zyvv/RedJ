//
//  OrderViewController.m
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "OrderViewController.h"
#import "Order.h"

@interface OrderViewController ()
@property (weak, nonatomic) IBOutlet UILabel *guestLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *letOrderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sizeOrderSegment;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (nonatomic, strong) Order *order;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ - %@", _match.guestTeam, _match.homeTeam];
    self.sureButton.enabled = NO;
    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AVQuery *query = [AVQuery queryWithClassName:@"Order"];
    [query whereKey:@"matchId" equalTo:_match.thirdId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (objects.count > 0) {
                AVObject *orderObj = objects.lastObject;
                NSMutableDictionary *orderDict = [orderObj dictionaryForObject];
                Order *order = [Order yy_modelWithJSON:orderDict];
                self.order = order;
                [self layoutWithOrder:order];
            } else {
                self.sureButton.enabled = YES;
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

- (void)layoutWithOrder:(Order *)order {
    if (order.letBetAmount > 0 && order.sizeBetAmount > 0) {
        self.sureButton.enabled = NO;
        [self.sureButton setTitle:@"已投注" forState:UIControlStateNormal];
    } else {
        self.sureButton.enabled = YES;
    }
    if (order.letBetAmount > 0) {
        _letSegment.selectedSegmentIndex = order.betGuest ? 1 : 2;
        _letOrderSegment.selectedSegmentIndex = order.letBetAmount / 10;
        _letSegment.enabled = _letOrderSegment.enabled = NO;
        
    }
    if (order.sizeBetAmount > 0) {
        _sizeSegment.selectedSegmentIndex = order.betBig ? 1 : 2;
        _sizeOrderSegment.selectedSegmentIndex = order.sizeBetAmount / 10;
        _sizeSegment.enabled = _sizeOrderSegment.enabled = NO;
    }
}

- (IBAction)sureButtonAction:(UIButton *)sender {

    AVObject *orderObj;
    if (self.order.objectId) {
        orderObj =[AVObject objectWithClassName:@"Order" objectId:self.order.objectId];
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [userOrderMapTom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            });
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
