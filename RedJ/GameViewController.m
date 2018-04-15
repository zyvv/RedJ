//
//  GameViewController.m
//  RedJ
//
//  Created by vi~ on 2018/4/13.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "GameViewController.h"
#import "LoginViewController.h"
#import "GameCell.h"
#import "Match.h"
#import "OrderViewController.h"
#import "User.h"
#import "Order.h"

@interface GameViewController ()<UITableViewDelegate, UITableViewDataSource>
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *matchDataArray;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"比赛";

    if (![AVUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController presentViewController:loginVC animated:NO completion:nil];
    } else {
    }
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshControlAction:nil];
    if (![AVUser currentUser]) {
        return;
    }
    
    if ([self isRankingTime]) {
        AVQuery *query1 = [AVQuery queryWithClassName:@"BetRanked"];
        [query1 whereKey:@"userName" equalTo:[User currentUser].username];
        AVQuery *query2 = [AVQuery queryWithClassName:@"BetRanked"];
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *nowStr = [dateFormat stringFromDate:now];
        [query2 whereKey:@"rankedDay" equalTo:nowStr];
        AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
        [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (!object) {
                [self needPanDian];
            }
        }];
    }
}

- (void)needPanDian {
    [self requestRankingMatch:^(id responseObject) {
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Bet"];
        [query1 whereKey:@"orderUserName" equalTo:[User currentUser].username];
        AVQuery *query2 = [AVQuery queryWithClassName:@"Bet"];
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *nowStr = [dateFormat stringFromDate:now];
        [query2 whereKey:@"matchDate" equalTo:nowStr];
        AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (results) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AVObject *obj in results) {
                    NSMutableDictionary *dict = [obj dictionaryForObject];
                    [tempArray addObject:dict];
                }
                NSArray *betsArray = [NSArray yy_modelArrayWithClass:[Bet class] json:tempArray];
                [self pandian:responseObject betsArray:betsArray];
            }
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)pandian:(NSArray *)matchsArray betsArray:(NSArray *)betsArray {
    if (!matchsArray || !betsArray) {
        return;
    }
    NSMutableArray *settledBetsArray = [NSMutableArray arrayWithCapacity:0];
    CGFloat totalEarning = 0;
    int hong = 0;
    int hei = 0;
    int totalEarningWithoutBenJin = 0;
    for (Bet *bet in betsArray) {
        for (Match *match in matchsArray) {
            if ([bet.matchId isEqualToString:match.thirdId]) {
                AVObject *obj = [AVObject objectWithClassName:@"Bet" objectId:bet.objectId];
                [obj setObject:@(YES) forKey:@"settle"];
                [obj setObject:[NSDate date] forKey:@"settleDate"];
                [obj setObject:[match yy_modelToJSONObject] forKey:@"match"];
//                bet.match = match;
//                bet.settle = YES;
//                bet.settleDate = [NSDate date];
                CGFloat betOdds = round(bet.betOdds * 100) / 100;
                if (bet.isSize) { // 大小分
                    CGFloat size = match.matchScore.guestScore + match.matchScore.homeScore;
                    if (bet.match.matchOdds.asiaSize.bet365.handicapValue == size) {
                        bet.earnings = bet.betAmount;
                        [obj setObject:@(bet.betAmount) forKey:@"earnings"];
                    } else {
                        BOOL sizeLeft ;
                        if (bet.match.matchOdds.asiaSize.bet365.handicapValue < size) { // 大分
                            sizeLeft = YES;
                        } else { // 小分
                            sizeLeft = NO;
                        }
                        bet.earnings = (1 + betOdds) * bet.betAmount;
//                        bet.status = 1;
                        [obj setObject:@((1 + betOdds) * bet.betAmount) forKey:@"earnings"];
                        [obj setObject:@(1) forKey:@"status"];
                        if (bet.leftOdds != sizeLeft) {
                            // 黑
                            bet.earnings = -(bet.betAmount);
//                            bet.status = -1;
                            [obj setObject:@(-bet.betAmount) forKey:@"earnings"];
                            [obj setObject:@(-1) forKey:@"status"];
                            hei++;
                        } else {
                            hong++;
                        }
                    }
                } else { // 让分
                    CGFloat let = match.matchScore.homeScore - match.matchScore.guestScore;
                    if (bet.match.matchOdds.asiaLet.bet365.handicapValue == let) {
                        bet.earnings = bet.betAmount;
                        [obj setObject:@(bet.betAmount) forKey:@"earnings"];
                    } else {
                        BOOL letLeft;
                        if (bet.match.matchOdds.asiaLet.bet365.handicapValue < let) { //
                            letLeft = NO;
                        } else {
                            letLeft = YES;
                        }
                        bet.earnings = (1 + betOdds) * bet.betAmount;
//                        bet.status = 1;
                        [obj setObject:@((1 + betOdds) * bet.betAmount) forKey:@"earnings"];
                        [obj setObject:@(1) forKey:@"status"];
                        if (bet.leftOdds != letLeft) {
                            // 黑
                            bet.earnings = -(bet.betAmount);
//                            bet.status = -1;
                            [obj setObject:@(-bet.betAmount) forKey:@"earnings"];
                            [obj setObject:@(-1) forKey:@"status"];
                            hei++;
                        } else {
                            hong++;
                        }
                    }
                }
                
                if (bet.earnings > 0) {
                    totalEarningWithoutBenJin += (bet.earnings - bet.betAmount);
                    totalEarning += bet.earnings;
                } else {
                    totalEarningWithoutBenJin += (bet.earnings);
                }
                
                [settledBetsArray addObject:obj];
            }
        }
    }
    [User currentUserAccount:^(Account *ac, NSError *error) {
        if (ac) {
            AVObject *accObj = [AVObject objectWithClassName:@"Account" objectId:ac.objectId];
            NSLog(@"-当前账户-- %.2f , %.2f", ac.balance, ac.totalAccount);
            NSLog(@"-加上账户-- %.2f , %.2f", totalEarning, totalEarning);
            [accObj setObject:@(ac.totalAccount + totalEarningWithoutBenJin) forKey:@"totalAccount"];
            [accObj setObject:@(ac.balance + totalEarning) forKey:@"balance"];
            [settledBetsArray addObject:accObj];
            NSError *error = nil;
            [AVObject saveAll:settledBetsArray error:&error];
            if (!error) {
                AVObject *obj = [AVObject objectWithClassName:@"BetRanked"];
                [obj setObject:[User currentUser].username forKey:@"userName"];
                NSDate *now = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                NSString *nowStr = [dateFormat stringFromDate:now];
                [obj setObject:nowStr forKey:@"rankedDay"];
                [obj setObject:@(hong) forKey:@"hong"];
                [obj setObject:@(hei) forKey:@"hei"];
                [obj setObject:@(totalEarningWithoutBenJin) forKey:@"totalEarning"];
                
                AVObject *userBetMapTom = [[AVObject alloc] initWithClassName:@"UserRanked"];// 用户投注
                [userBetMapTom setObject:[AVUser currentUser] forKey:@"user"];
                [userBetMapTom setObject:obj forKey:@"ranked"];
                userBetMapTom.fetchWhenSave = YES;
                [userBetMapTom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                }];
            }
        }
    }];
}

- (void)setMatchDataArray:(NSArray *)matchDataArray {
    if (matchDataArray != _matchDataArray) {
        _matchDataArray = matchDataArray;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GameCell" owner:self options:nil] lastObject];
    }
    Game *game = self.matchDataArray[indexPath.section];
    cell.match = game.matchs[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.matchDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Game *game = self.matchDataArray[section];
    return game.matchs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Game *game = self.matchDataArray[indexPath.section];
    OrderViewController *orderVC = [[OrderViewController alloc] init];
    orderVC.match = game.matchs[indexPath.row];
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC
                                         animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] init];
    header.textColor = [UIColor darkTextColor];
    header.font = [UIFont systemFontOfSize:17];
    header.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
    Game *game = self.matchDataArray[section];
    header.text = game.date;
    return header;
}

- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    [self requestMatchSuccess:^(id responseObject) {
        self.matchDataArray = (NSArray *)responseObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender endRefreshing];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestLiveMatchSuccess:(PPHttpRequestSuccess)success
                        failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findLiveMatch.do" parameters:[self requestPrameters] success:success failure:failure];
}

- (void)requestScheduledMatchSuccess:(PPHttpRequestSuccess)success
                             failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findScheduledMatch.do" parameters:[self requestPrameters] success:success failure:failure];
}

- (void)requestFinishedMatchSuccess:(PPHttpRequestSuccess)success
                             failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findFinishedMatch.do" parameters:[self requestPrameters] success:success failure:failure];
}

-(void)requestRankingMatch:(PPHttpRequestSuccess)success
                   failure:(PPHttpRequestFailed)failure {
    [self requestFinishedMatchSuccess:^(id responseObject) {
        ResponseModel *finishedModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (finishedModel.result == 200) {
            for (MatchData *matchData in finishedModel.matchData) {
                if (matchData.diffDays == 0) { // 今天的比赛
                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                    for (Match *match in matchData.match) {
                        if ([match.leagueId isEqualToString:@"1"]) {
                            [matchs addObject:match];
                        }
                    }
                    success(matchs);
                }
            }
            
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:finishedModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
            failure(error);
        }
    } failure:failure];
}

- (void)requestMatchSuccess:(PPHttpRequestSuccess)success
                    failure:(PPHttpRequestFailed)failure {
    [self requestLiveMatchSuccess:^(id responseObject) {
        ResponseModel *liveModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (liveModel.result == 200) {
            [self requestScheduledMatchSuccess:^(id responseObject) {
                ResponseModel *scheduledModel = [ResponseModel yy_modelWithJSON:responseObject];
                if (scheduledModel.result == 200) {
                    NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:0];
                    
                    for (MatchData *matchData in liveModel.matchData) {
                        if (matchData.diffDays == 0) { // 正在进行的比赛
                            Game *game = [Game new];
                            game.date = matchData.date;
                            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                            for (Match *match in matchData.match) {
                                if ([match.leagueId isEqualToString:@"1"]) {
                                    [matchs addObject:match];
                                }
                            }
                            game.matchs = matchs;
                            if (matchs.count > 0) {
                                [responseArray addObject:game];
                            }
                        }
                        
                        if (matchData.diffDays == 1) { // 明日比赛
                            Game *game = [Game new];
                            game.date = matchData.date;
                            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                            for (Match *match in matchData.match) {
                                if ([match.leagueId isEqualToString:@"1"]) {
                                    [matchs addObject:match];
                                }
                            }
                            game.matchs = matchs;
                            if (matchs.count > 0) {
                                [responseArray addObject:game];
                            }
                        }
                    }
                    
                    for (MatchData *matchData in scheduledModel.matchData) {
                        if (matchData.diffDays == 1) { // 计划表中明天的比赛
                            Game *game = [Game new];
                            game.date = matchData.date;
                            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                            for (Match *match in matchData.match) {
                                if ([match.leagueId isEqualToString:@"1"]) {
                                    [matchs addObject:match];
                                }
                            }
                            game.matchs = matchs;
                            if (matchs.count > 0) {
                                [responseArray addObject:game];
                            }
                        }
                    }
                    
                    success(responseArray);
                    
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:scheduledModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
                    failure(error);
                }
            } failure:failure];
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:liveModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
            failure(error);
        }

    } failure:failure];
}

- (NSDictionary *)requestPrameters {
    return @{
             @"version": @"240",
             @"userId": @"",
             @"timeZone": @"8",
             @"sign": @"48fb6a2abcba80554892266fc6398649fb",
             @"loginToken": @"",
             @"lang": @"zh",
             @"deviceToken": @"",
             @"deviceId": @"5BAD9C8825214AB782C7D0B7216F5454",
             @"appno": @"11",
             @"appType": @"1",
             @"_": [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]]
             };
}

- (BOOL)isRankingTime {

    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];

    NSString *nowStr = [dateFormat stringFromDate:now];
    now = [dateFormat dateFromString:nowStr];
    
    NSDate *rankingTime = [dateFormat dateFromString:@"15:00"];
    
    if ([now compare:rankingTime] == NSOrderedDescending) {
        return YES;
    }
    return NO;
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
