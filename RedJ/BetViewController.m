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

@interface BetViewController ()

@property (nonatomic, strong) Match *lastMatch;
@property (nonatomic, strong) Account *account;

@end

@implementation BetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ - %@", _match.guestTeam, _match.homeTeam];
    [User currentUserAccount:^(Account *account, NSError *error) {
        self.account = account;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [self.tableView reloadData];
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
        cell.pankou = _match.matchOdds.asiaLet.bet365;
    }
    if (indexPath.item == 1) {
        cell.pankou = _match.matchOdds.asiaSize.bet365;
    }
    if (indexPath.item == 2) {
        cell.pankou = _match.matchOdds.euro.euro;
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
    [bet bet:self.account betBlock:^(BOOL success, BOOL appendBet, Account *account, NSError *error) {
        if (success) {
            if (appendBet) {
                hud.label.text = @"追加成功";
            } else {
                hud.label.text = @"下注成功";
            }
            self.account = account;
        } else {
            hud.label.text = @"下注失败";
        }
        [hud hideAnimated:YES afterDelay:.25];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end