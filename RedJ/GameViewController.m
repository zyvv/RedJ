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
