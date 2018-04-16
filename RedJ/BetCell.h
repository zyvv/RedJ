//
//  BetCell.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import "Order.h"
#import "Account.h"

@class  BetCell;
typedef void(^willBetBlock)(BetCell *cell, Bet *bet);

@interface BetCell : UITableViewCell

@property (nonatomic, strong) Match *match;
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) Pankou *pankou;
@property (nonatomic, assign) int betType;
@property (nonatomic, copy) willBetBlock willBetBlock;

@end
