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
#import "RequestList.h"
#import "UserSettle.h"


@interface RankingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshItem;
@property (nonatomic, copy) NSArray *userRankingArray;
@end

@implementation RankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"统计";
    
    UIView *footerView = [UIView new];
    footerView.frame = CGRectMake(0, 0, 320, 100);
    self.tableView.tableFooterView = footerView;
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, 300, 50);
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"统计数据在每个比赛日的下午3:05开始更新。";
    self.tableView.tableHeaderView = label;
    [self refreshControlAction:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView.refreshControl endRefreshing];
}


- (void)fecthRankData:(void (^)(void))completion {
    AVQuery *query = [AVQuery queryWithClassName:@"BetRanked"];
    if ([UserSettle isRankingDuration]) {
        [query whereKey:@"rankedDay" equalTo:[UserSettle formatToday]];
    } else {
        [query whereKey:@"rankedDay" equalTo:[UserSettle formatYesterday]];
    }
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
                            userRanking.totalAccount = ranking.totalAccount;
                            userRanking.todayPay = ranking.todayPay;
                            userRanking.rankedDay = ranking.rankedDay;
                        }
                    }
                    [userRankArray addObject:userRanking];
                }
                
                NSArray *sortUserRankArray = [userRankArray sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    UserRanking *rank1 = obj1;
                    UserRanking *rank2 = obj2;
                    if (rank1.todayEarning < rank2.todayEarning) {
                        return NSOrderedDescending;
                    } else if (rank1.todayEarning > rank2.todayEarning) {
                        return NSOrderedAscending;
                    } else {
                        return NSOrderedSame;
                    }
                }];
                
                self.userRankingArray = sortUserRankArray;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) { completion(); }
                });
            });
        } else {
            if (completion) { completion(); }
        }
    }];
}

- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    [self fecthRankData:^{
        [sender endRefreshing];
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
    cell.ranking = (int)indexPath.row + 1;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userRankingArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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
