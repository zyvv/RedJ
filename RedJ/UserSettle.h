//
//  UserSettle.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettle : NSObject

+ (BOOL)isRankingDuration;

+ (BOOL)isSettleTime;

+ (NSString *)formatToday;

+ (NSString *)formatYesterday;

+ (void)settleAndUploadTodayEarning;

+ (BOOL)beingSettled;

@end
