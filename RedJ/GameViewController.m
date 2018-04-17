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
#import "RequestList.h"
#import "BetViewController.h"
#import "UserSettle.h"

@interface GameViewController ()<UITableViewDelegate, UITableViewDataSource>
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *matchDataArray;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *dateFormatter2;
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
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, 300, 49);
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.contentMode = UIViewContentModeBottom;
    label.text = [NSString stringWithFormat:@"%@ %@(%@)", app_Name, app_Version, app_build];
    self.tableView.tableFooterView = label;
    
    [UserSettle settleAndUploadTodayEarning];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Game *game = self.matchDataArray[indexPath.section];
    [self performSegueWithIdentifier:@"PushBetVC" sender:game.matchs[indexPath.row]];
//    OrderViewController *orderVC = [[OrderViewController alloc] init];
//    orderVC.match = game.matchs[indexPath.row];
//    orderVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:orderVC
//                                         animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor blackColor];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,8, 375, 34)];
    headerView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:headerView];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(16,5, 375, 24)];
    header.textColor = [UIColor darkTextColor];
    header.font = [UIFont systemFontOfSize:16];
    Game *game = self.matchDataArray[section];
    NSDate *date = [self.dateFormatter dateFromString:game.date];
    NSString *dateString = [self.dateFormatter2 stringFromDate:date] ;
    header.text = dateString;
    [headerView addSubview:header];
    return bgView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}


- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    [RequestList requestMatchSuccess:^(id responseObject) {
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PushBetVC"]) {
        BetViewController *betVC = (BetViewController *)segue.destinationViewController;
        betVC.match = (Match *)sender;
    }
}
- (NSDateFormatter*)dateFormatter{
    if (!_dateFormatter){
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return  _dateFormatter;
}
- (NSDateFormatter*)dateFormatter2{
    if (!_dateFormatter2){
        _dateFormatter2 = [NSDateFormatter new];
        _dateFormatter2.dateFormat = @"MM月dd日 EEEE";
    }
    return  _dateFormatter2;
}

@end
