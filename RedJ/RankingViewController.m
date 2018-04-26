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
#import "BetListCell.h"


@interface RankingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic, copy) NSArray *userRankingArray;
@property (nonatomic, copy) NSArray *userBetListArray;

@property (nonatomic, strong) UILabel *headerLabel;

@end

@implementation RankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"统计";
    
    UIView *footerView = [UIView new];
    footerView.frame = CGRectMake(0, 0, 320, 100);
    self.tableView.tableFooterView = footerView;
    self.headerLabel = [UILabel new];
    self.headerLabel.frame = CGRectMake(0, 0, 300, 50);
    self.headerLabel.textColor = [UIColor darkGrayColor];
    self.headerLabel.font = [UIFont systemFontOfSize:12];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = self.headerLabel;
    [self refreshControlAction:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UserSettle settleAndUploadTodayEarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView.refreshControl endRefreshing];
}


- (void)fecthRankData {

    AVQuery *query = [AVQuery queryWithClassName:@"BetRanked"];
    [query whereKey:@"rankedDay" equalTo:[UserSettle formatToday]];
    [query addDescendingOrder:@"totalEarning"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AVObject *obj in objects) {
                    NSMutableDictionary *dict = [obj dictionaryForObject];
                    [tempArray addObject:dict];
                }
                self.userRankingArray = [NSArray yy_modelArrayWithClass:[Ranking class] json:tempArray];
            });
        }
        [self.tableView.refreshControl endRefreshing];
    }];
}

- (void)fetchUserBetList {
    AVQuery *query = [AVQuery queryWithClassName:@"Bet"];
    [query whereKey:@"orderUserName" equalTo:[User currentUser].username];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AVObject *obj in objects) {
                    NSMutableDictionary *dict = [obj dictionaryForObject];
                    [tempArray addObject:dict];
                }
                NSArray *betsArray = [NSArray yy_modelArrayWithClass:[Bet class] json:tempArray];
                if (betsArray) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.userBetListArray = betsArray;
                    });
                }
            });
        }
        [self.tableView.refreshControl endRefreshing];
    }];
}

- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    [self segmentControlAction:self.segmentControl];
}
- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.headerLabel.text = @"下注记录";
        [self fetchUserBetList];
    } else {
        self.headerLabel.text = @"实时排名";
        [self fecthRankData];
    }
}

- (void)setUserRankingArray:(NSArray *)userRankingArray {
    if (_userRankingArray != userRankingArray) {
        _userRankingArray = userRankingArray;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView.refreshControl endRefreshing];
    });
}

- (void)setUserBetListArray:(NSArray *)userBetListArray {
    if (_userBetListArray != userBetListArray) {
        _userBetListArray = userBetListArray;
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
    if (_segmentControl.selectedSegmentIndex == 0) {
        BetListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BetListCell" forIndexPath:indexPath];
        cell.bet = self.userBetListArray[indexPath.row];
        return cell;
    }
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RankingCell" forIndexPath:indexPath];
    cell.userRanking = self.userRankingArray[indexPath.row];
    cell.ranking = (int)indexPath.row + 1;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return self.userBetListArray.count;
    }
    return self.userRankingArray.count;
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
