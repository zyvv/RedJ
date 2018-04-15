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

@interface RankingViewController ()<UITableViewDelegate, UITableViewDataSource>
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
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *nowStr = [dateFormat stringFromDate:now];
    [query2 whereKey:@"rankedDay" equalTo:nowStr];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
