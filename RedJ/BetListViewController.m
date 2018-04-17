//
//  BetListViewController.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/17.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetListViewController.h"
#import "BetListCell.h"

@interface BetListViewController ()

@property (nonatomic, copy) NSArray *betsArray;

@end

@implementation BetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVQuery *query1 = [AVQuery queryWithClassName:@"Bet"];
    [query1 whereKey:@"matchId" equalTo:_match.thirdId];
    AVQuery *query2 = [AVQuery queryWithClassName:@"Bet"];
    [query2 whereKey:@"orderUserName" equalTo:[User currentUser].username];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
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
                        self.betsArray = betsArray;
                    });
                }
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBetsArray:(NSArray *)betsArray {
    if (_betsArray != betsArray) {
        _betsArray = betsArray;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.betsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BetListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BetListCell" forIndexPath:indexPath];
    cell.bet = self.betsArray[indexPath.row];
    return cell;
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
