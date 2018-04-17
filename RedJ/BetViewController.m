//
//  BetViewController.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetViewController.h"
#import "BetCell.h"
#import "BetHeaderView.h"
#import "Account.h"
#import "BetListViewController.h"
#import "RequestList.h"
#import "UserSettle.h"

typedef void(^RequestOddsBlock)(BOOL success, Pankou *pankou, NSError *error);
typedef void(^RequestMatchBlock)(BOOL success, Match *match, NSError *error);

@interface BetViewController ()

@property (nonatomic, strong) Match *lastMatch;
@property (nonatomic, strong) Account *account;

@property (nonatomic, strong) Pankou *letOdds;
@property (nonatomic, strong) Pankou *sizeOdds;
@property (nonatomic, strong) Pankou *euroOdds;

@property (nonatomic, assign) int refreshedCount;

@end

@implementation BetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - %@", _match.guestTeam, _match.homeTeam];
    [User currentUserAccount:^(Account *account, NSError *error) {
        self.account = account;
    }];
    [self refreshControlAction:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.tableView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self.tableView removeObserver:self forKeyPath:@"contentInset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (![keyPath isEqualToString:@"contentInset"]) { return; }
    if (!self.tableView.tracking) { return;}
    if (!change) { return; }
    
    NSValue *oldValue = nil;
    for (NSString *key in change.allKeys) {
        if ([key isEqualToString:@"old"]) {
            oldValue = change[key];
            break;
        }
    }
    if (!oldValue) { return; }
    CGFloat diff = self.tableView.contentInset.top - oldValue.UIEdgeInsetsValue.top;
    CGPoint translation = [self.tableView.panGestureRecognizer translationInView:self.tableView];
    translation.y -= (diff * 3.0 / 2.0);
    [self.tableView.panGestureRecognizer setTranslation:translation inView:self.tableView];
}

- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    if (_match.matchStatus == -1 || (_match.matchStatus != 0 && _match.matchStatus != -1)) {
        [sender endRefreshing];
        return;
    }
    _refreshedCount = 0;
    [self requestMatchScore:nil];
    [self requestLetOdds:nil];
    [self requestSizeOdds:nil];
    [self requestEuroOdds:nil];
}

- (void)requestMatchScore:(RequestMatchBlock)requestMatchBlock {
    [RequestList requestMatchScore:_match.thirdId success:^(id responseObject) {
        MatchScoreModel *scoreModel = [MatchScoreModel yy_modelWithJSON:responseObject];
        if (scoreModel.result == 200) {
            self.match = scoreModel.data;
        }
        ++self.refreshedCount;
        if (requestMatchBlock) {
            requestMatchBlock(YES, scoreModel.data, nil);
        }
    } failure:^(NSError *error) {
        ++self.refreshedCount;
        if (requestMatchBlock) {
            requestMatchBlock(NO, nil, error);
        }
    }];
}

- (void)requestLetOdds:(RequestOddsBlock)requestOddsBlock {
    [RequestList requestMatchOdds:_match.thirdId oddsType:0 success:^(id responseObject) {
        CompanyOdds *companyOdds = [CompanyOdds yy_modelWithJSON:responseObject];
        self.letOdds = companyOdds.bet365;
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(YES, companyOdds.bet365, nil);
        }
    } failure:^(NSError *error) {
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(NO, nil, error);
        }
    }];
}

- (void)requestSizeOdds:(RequestOddsBlock)requestOddsBlock {
    [RequestList requestMatchOdds:_match.thirdId oddsType:1 success:^(id responseObject) {
        CompanyOdds *companyOdds = [CompanyOdds yy_modelWithJSON:responseObject];
        self.sizeOdds = companyOdds.bet365;
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(YES, companyOdds.bet365, nil);
        }
    } failure:^(NSError *error) {
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(NO, nil, error);
        }
    }];
    
}

- (void)requestEuroOdds:(RequestOddsBlock)requestOddsBlock {
    [RequestList requestMatchOdds:_match.thirdId oddsType:2 success:^(id responseObject) {
        CompanyOdds *companyOdds = [CompanyOdds yy_modelWithJSON:responseObject];
        self.euroOdds = companyOdds.bet365;
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(YES, companyOdds.bet365, nil);
        }
    } failure:^(NSError *error) {
        ++self.refreshedCount;
        if (requestOddsBlock) {
            requestOddsBlock(NO, nil, error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMatch:(Match *)match {
    if (_match != match) {
        _match = match;
    }
    _lastMatch = _match;
    if (self.tableView) {
        [self.tableView reloadData];
    }
}

- (void)setLetOdds:(Pankou *)letOdds {
    if (_letOdds != letOdds) {
        _letOdds = letOdds;
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setSizeOdds:(Pankou *)sizeOdds {
    if (_sizeOdds != sizeOdds) {
        _sizeOdds = sizeOdds;
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setEuroOdds:(Pankou *)euroOdds {
    if (_euroOdds != euroOdds) {
        _euroOdds = euroOdds;
    }
    [self.tableView reloadData];
//    [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setRefreshedCount:(int)refreshedCount {
    _refreshedCount = refreshedCount;
    if (_refreshedCount == 4) {
        [self.tableView.refreshControl endRefreshing];
    }
}

- (void)setAccount:(Account *)account {
    if (_account != account) {
        _account = account;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BetCell" forIndexPath:indexPath];
    cell.match = _match;
    cell.betType = (int)indexPath.item;
    if (indexPath.item == 0) {
        cell.pankou = _letOdds;
    }
    if (indexPath.item == 1) {
        cell.pankou = _sizeOdds;
    }
    if (indexPath.item == 2) {
        cell.pankou = _euroOdds;
    }
    
    __weak BetViewController *weakSelf = self;
    cell.willBetBlock = ^(BetCell *betCell, Bet *bet) {
        [weakSelf uploadBet:bet];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BetHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"BetHeaderView" owner:self options:nil] lastObject];
    headerView.match = _match;
    headerView.account = _account;
    return headerView;
}

- (void)uploadBet:(Bet *)bet {
    if (self.account.balance < bet.betAmount) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"余额不足";
        [hud hideAnimated:YES afterDelay:.5];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [self requestMatchScore:^(BOOL success, Match *match, NSError *error) {
        if (!success) {
            hud.label.text = @"更新比赛信息失败";
            [hud hideAnimated:YES afterDelay:.25];
            return;
        } else if (_match.matchStatus == -1) {
            hud.label.text = @"比赛已结束";
            [hud hideAnimated:YES afterDelay:.25];
            return;
        } else if (_match.matchStatus != 0) {
            hud.label.text = @"比赛已开始";
            [hud hideAnimated:YES afterDelay:.25];
            return;
        } else {
            RequestOddsBlock oddsBlock = ^(BOOL success, Pankou *pankou, NSError *error) {
                if (!success) {
                    hud.label.text = @"更新盘口信息失败";
                    [hud hideAnimated:YES afterDelay:.25];
                    return;
                }
                if (pankou.leftOdds != bet.leftOddsValue || pankou.rightOdds != bet.rightOddsValue || pankou.handicapValue != bet.handicapValue) {
                    hud.label.text = @"盘口已更新，请重新下注";
                    [hud hideAnimated:YES afterDelay:.25];
                    return;
                } else {
                    
                    if ([UserSettle beingSettled]) {
                        hud.label.text = @"系统正在结算，请在15:10之后下注";
                        [hud hideAnimated:YES afterDelay:.25];
                        return;
                    }
                    
                    [bet bet:self.account betBlock:^(BOOL success, BOOL appendBet, Account *account, NSError *error) {
                        if (success) {
                            if (appendBet) {
                                hud.label.text = @"追加成功";
                            } else {
                                hud.label.text = @"下注成功";
                            }
                            self.account = account;
                            if ([UserSettle isRankingDuration]) {
                                AVQuery *query = [AVQuery queryWithClassName:@"BetRanked"];
                                [query whereKey:@"rankedDay" equalTo:[UserSettle formatToday]];
                                [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
                                    if (object) {
                                        [object setObject:@(account.totalAccount - account.balance) forKey:@"todayPay"];
                                        [object saveInBackground];
                                    }
                                }];
                            }
                        } else {
                            hud.label.text = @"下注失败";
                        }
                        [hud hideAnimated:YES afterDelay:.25];
                    }];
                }
            };
            
            if (bet.betType == 0) { [self requestLetOdds:oddsBlock]; }
            if (bet.betType == 1) { [self requestSizeOdds:oddsBlock]; }
            if (bet.betType == 2) { [self requestEuroOdds:oddsBlock]; }
        }
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowBetList"]) {
        BetListViewController *betListVC = (BetListViewController *)segue.destinationViewController;
        betListVC.match = _match;
        betListVC.title = [NSString stringWithFormat:@"%.0f - %.0f", _match.matchScore.guestScore, _match.matchScore.homeScore];
    }
}


@end
