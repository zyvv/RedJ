//
//  BetCell.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"

@interface BetCell : UITableViewCell

@property (nonatomic, strong) Match *match;
@property (nonatomic, strong) Pankou *pankou;
@property (nonatomic, assign) int betType;

@end
