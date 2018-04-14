//
//  Match.h
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Pankou : NSObject

@property (nonatomic, copy) NSString *handicap;

/**
 主队让分 / 大小分盘口
 */
@property (nonatomic, assign) float handicapValue;


/**
 客队赔率 / 大分
 */
@property (nonatomic, assign) float leftOdds;

/**
 主队赔率 / 小分
 */
@property (nonatomic, assign) float rightOdds;

@end


@interface AsiaLet : NSObject
@property (nonatomic, strong) Pankou *bet365;
@end

@interface AsiaSize : NSObject
@property (nonatomic, strong) Pankou *bet365;
@end

@interface MatchOdds : NSObject
@property (nonatomic, strong) AsiaLet *asiaLet; // 让分
@property (nonatomic, strong) AsiaSize *asiaSize; // 大小分
@end

@interface Match : NSObject
@property (nonatomic, copy) NSString *leagueId; // 联赛id
@property (nonatomic, copy) NSString *thirdId; // 比赛id
@property (nonatomic, copy) NSString *homeTeam; // 主队名字
@property (nonatomic, copy) NSString *guestTeam; // 客队名字
@property (nonatomic, copy) NSString *date; // 比赛日期
@property (nonatomic, copy) NSString *time; // 比赛时间
@property (nonatomic, assign) int matchStatus; // 比赛状态 -1(已经结束) ... 0(未开始) ... xx
@property (nonatomic, copy) NSString *homeTeamId; // 主队id
@property (nonatomic, copy) NSString *guestTeamId; // 客队id
@property (nonatomic, strong) NSURL *homeLogoUrl; // 主队logo
@property (nonatomic, strong) NSURL *guestLogoUrl; // 客队logo
@property (nonatomic, strong) MatchOdds *matchOdds; // 比赛盘口
@end

@interface MatchData : NSObject
@property (nonatomic, assign) int diffDays;
@property (nonatomic, copy) NSArray *match;
@property (nonatomic, copy) NSString *date;
@end

@interface ResponseModel : NSObject
@property (nonatomic, assign) int result;
@property (nonatomic, copy) NSArray *matchData;
@end


@interface Game : NSObject
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSArray *matchs;
@end

