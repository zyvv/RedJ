//
//  RankingViewController.m
//  RedJ
//
//  Created by vi~ on 2018/4/15.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "RankingViewController.h"
#import "RankingCell.h"
#import "User.h"
#import "Ranking.h"
#import "Order.h"

@interface RankingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshItem;
@property (nonatomic, copy) NSArray *userRankingArray;
@end

@implementation RankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"统计";
    self.tableView.tableFooterView = [UIView new];
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, 300, 50);
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"统计数据在每个比赛日的下午3:05开始更新。";
    self.tableView.tableHeaderView = label;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isRankingTime]) {
        [self fecthRankData];
    }
}

- (void)fecthRankData {
    AVQuery *query2 = [AVQuery queryWithClassName:@"BetRanked"];
    [query2 whereKey:@"rankedDay" equalTo:[self formatToday]];
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[query2]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AVObject *obj in objects) {
                    NSMutableDictionary *dict = [obj dictionaryForObject];
                    [tempArray addObject:dict];
                }
                NSArray *rankArray = [NSArray yy_modelArrayWithClass:[Ranking class] json:tempArray];
                
                NSMutableSet *usernameSet = [NSMutableSet set];
                for (Ranking *ranking in rankArray) {
                    if (ranking.userName) {
                        [usernameSet addObject:ranking.userName];
                    }
                }
                NSMutableArray *userRankArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSString *userName in usernameSet) {
                    UserRanking *userRanking = [UserRanking new];
                    userRanking.userName = userName;
                    for (Ranking *ranking in rankArray) {
                        if ([userName isEqualToString:ranking.userName]) {
                            userRanking.hong += ranking.hong;
                            userRanking.hei += ranking.hei;
                            userRanking.todayEarning = ranking.totalEarning;
                        }
                    }
                    [userRankArray addObject:userRanking];
                }
                
                self.userRankingArray = [userRankArray copy];
            });
        }
    }];
}

- (void)settleAndUploadTodayEarning {
    if (![AVUser currentUser]) {
        return;
    }
    if (![self isRankingTime]) {
        return;
    }
    NSString *rankedFlag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Ranked_%@",[User currentUser].username]];
    if (rankedFlag && [rankedFlag isEqualToString:[self formatToday]]) {
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
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[self formatToday] forKey:[NSString stringWithFormat:@"Ranked_%@",[User currentUser].username]];
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


- (IBAction)refreshItemAction:(UIBarButtonItem *)sender {
}

- (void)setUserRankingArray:(NSArray *)userRankingArray {
    if (_userRankingArray != userRankingArray) {
        _userRankingArray = userRankingArray;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RankingCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RankingCell" owner:self options:nil] lastObject];
    }
    cell.userRanking = self.userRankingArray[indexPath.row];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userRankingArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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

- (NSString *)formatToday {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    return [dateFormat stringFromDate:now];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
