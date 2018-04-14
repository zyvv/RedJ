//
//  Order.h
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property (nonatomic, copy) NSString *objectId; // 存储id
@property (nonatomic, copy) NSString *matchId; // 比赛id

@property (nonatomic, assign) float letOdds; // 让分赔率
@property (nonatomic, assign) float letBetAmount; // 让分下注金额
@property (nonatomic, assign) BOOL betGuest; // 投注的是否是客队

@property (nonatomic, assign) float sizeValue; // 大小分数值
@property (nonatomic, assign) float sizeOdds; // 大小分赔率
@property (nonatomic, assign) float sizeBetAmount; // 大小分下注金额
@property (nonatomic, assign) BOOL betBig; // 投注的是否是大分

@property (nonatomic, assign) BOOL settle; // 是否结算
@property (nonatomic, assign) float earnings; // 此单收益
@property (nonatomic, assign) int status; //  -1未结算 0黑 1红
@property (nonatomic, strong) NSDate *orderDate; // 下单日期
@property (nonatomic, copy) NSString *gameDate; // 比赛日期
@property (nonatomic, strong) NSDate *settleDate; // 结算日期

@end
