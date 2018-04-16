//
//  BetHeaderView.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Match.h"
#import "Account.h"

@interface BetHeaderView : UIView

@property (nonatomic, strong) Match *match;
@property (nonatomic, strong) Account *account;

@end
