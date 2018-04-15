//
//  Ranking.h
//  RedJ
//
//  Created by vi~ on 2018/4/15.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ranking : NSObject

@property (nonatomic, copy) NSString *objectId; // 存储id
@property (nonatomic, copy) NSString *userName; // 用户昵称
@property (nonatomic, assign) float totalEarning; // 盈利
@property (nonatomic, copy) NSString *rankedDay; // 日期
@property (nonatomic, assign) int hong; // 红
@property (nonatomic, assign) int hei; // 黑

@end

@interface UserRanking : NSObject

@property (nonatomic, copy) NSString *userName; // 用户昵称
@property (nonatomic, assign) float todayPay; // 今日投注
@property (nonatomic, assign) float todayEarning; // 今日盈利
@property (nonatomic, assign) float totalAccount; // 总金额
@property (nonatomic, copy) NSString *rankedDay; // 日期
@property (nonatomic, assign) int hong; // 红单
@property (nonatomic, assign) int hei; // 黑单

@end
