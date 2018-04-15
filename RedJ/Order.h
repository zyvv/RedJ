//
//  Order.h
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Match.h"

typedef void (^betBlock)(BOOL success, Account *account, NSError *error);

@interface Order : NSObject

@property (nonatomic, copy) NSString *objectId; // 存储id
@property (nonatomic, copy) NSString *matchId; // 比赛id

@property (nonatomic, assign) float letOdds; // 让分赔率
@property (nonatomic, assign) float letBetAmount; // 让分下注金额
@property (nonatomic, assign) BOOL betGuest; // 投注的是否是客队
@property (nonatomic, assign) float letValue; // 让分多少

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

@property (nonatomic, copy) NSString *orderUserName; // 投注用户昵称

@end

@interface Bet : NSObject

@property (nonatomic, copy) NSString *objectId; // 存储id

@property (nonatomic, copy) NSString *orderUserName; // 投注用户昵称

@property (nonatomic, copy) NSString *matchId; // 比赛id
@property (nonatomic, assign) float betOdds; // 下注赔率
@property (nonatomic, assign) float betAmount; // 下注金额
@property (nonatomic, assign) BOOL leftOdds; // 投注的是否是大分(客队让分)
@property (nonatomic, assign) BOOL isSize; //  投注的是否是大小分类型

@property (nonatomic, assign) BOOL settle; // 是否结算
@property (nonatomic, assign) float earnings; // 此单收益
@property (nonatomic, assign) int status; //  -1黑 0未结算 1红
@property (nonatomic, strong) NSDate *betDate; // 下单日期
@property (nonatomic, copy) NSString *matchDate; // 比赛日期
@property (nonatomic, strong) Match *match; // 比赛
@property (nonatomic, strong) NSDate *settleDate; // 结算日期

- (AVObject *)betModelToAVObj;

- (void)bet:(Account *)account betBlock:(betBlock)betBlock;

@end
