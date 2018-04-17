//
//  RequestList.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "RequestList.h"
#import "Match.h"

#define kRequestPath(path) [NSString stringWithFormat:@"http://m.13322.com/mlottery/core/%@", path]

@implementation RequestList

+ (void)requestMatchSuccess:(PPHttpRequestSuccess)success
                    failure:(PPHttpRequestFailed)failure {
    [RequestList requestFinishedMatchSuccess:^(id responseObject) {
        ResponseModel *finishedModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (finishedModel.result == 200) {
            [RequestList requestLiveMatchSuccess:^(id responseObject) {
                ResponseModel *liveModel = [ResponseModel yy_modelWithJSON:responseObject];
                if (liveModel.result == 200) {
                    [self requestScheduledMatchSuccess:^(id responseObject) {
                        ResponseModel *scheduledModel = [ResponseModel yy_modelWithJSON:responseObject];
                        if (scheduledModel.result == 200) {
                            
                            NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:0];
                            
                            for (MatchData *matchData in finishedModel.matchData) {
                                if (matchData.diffDays == -1) { // 已经结束的昨天的比赛
                                    Game *game = [Game new];
                                    game.date = matchData.date;
                                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                                    for (Match *match in matchData.match) {
                                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                                            [matchs addObject:match];
                                        }
                                    }
                                    game.matchs = matchs;
                                    if (matchs.count > 0) {
                                        [responseArray addObject:game];
                                    }
                                }
                            }
                        
                            for (MatchData *matchData in finishedModel.matchData) {
                                if (matchData.diffDays == 0) { // 已经结束的今天的比赛
                                    Game *game = [Game new];
                                    game.date = matchData.date;
                                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                                    for (Match *match in matchData.match) {
                                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                                            [matchs addObject:match];
                                        }
                                    }
                                    game.matchs = matchs;
                                    if (matchs.count > 0) {
                                        [responseArray addObject:game];
                                    }
                                }
                            }
                        
                            
                            for (MatchData *matchData in liveModel.matchData) {
                                if (matchData.diffDays == 0) { // 正在进行的比赛
                                    Game *game = [Game new];
                                    game.date = matchData.date;
                                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                                    for (Match *match in matchData.match) {
                                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                                            [matchs addObject:match];
                                        }
                                    }
                                    game.matchs = matchs;
                                    if (matchs.count > 0) {
                                        [responseArray addObject:game];
                                    }
                                }
                                
                                if (matchData.diffDays == 1) { // 明日即将进行的比赛
                                    Game *game = [Game new];
                                    game.date = matchData.date;
                                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                                    for (Match *match in matchData.match) {
                                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                                            [matchs addObject:match];
                                        }
                                    }
                                    game.matchs = matchs;
                                    if (matchs.count > 0) {
                                        [responseArray addObject:game];
                                    }
                                }
                            }
                            
                            for (MatchData *matchData in scheduledModel.matchData) {
                                if (matchData.diffDays == 1) { // 计划表中明天的比赛
                                    Game *game = [Game new];
                                    game.date = matchData.date;
                                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                                    for (Match *match in matchData.match) {
                                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                                            [matchs addObject:match];
                                        }
                                    }
                                    game.matchs = matchs;
                                    if (matchs.count > 0) {
                                        [responseArray addObject:game];
                                    }
                                }
                            }
                            
                            success(responseArray);
                            
                        } else {
                            NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:scheduledModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
                            failure(error);
                        }
                    } failure:failure];
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:liveModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
                    failure(error);
                }
                
            } failure:failure];
        }
    } failure:failure];

}

+ (void)requestFinishedMatchSuccess:(PPHttpRequestSuccess)success
                            failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:kRequestPath(@"basketballMatch.findFinishedMatch.do") parameters:[self requestPrameters] success:success failure:failure];
}

+ (void)requestRankingMatch:(PPHttpRequestSuccess)success
                   failure:(PPHttpRequestFailed)failure {
    [RequestList requestFinishedMatchSuccess:^(id responseObject) {
        ResponseModel *finishedModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (finishedModel.result == 200) {
            for (MatchData *matchData in finishedModel.matchData) {
                if (matchData.diffDays == 0) { // 今天的比赛
                    NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                    for (Match *match in matchData.match) {
                        if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                            [matchs addObject:match];
                        }
                    }
                    success(matchs);
                }
            }
            
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:finishedModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
            failure(error);
        }
    } failure:failure];
}

+ (void)requestLiveMatchSuccess:(PPHttpRequestSuccess)success
                        failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:kRequestPath(@"basketballMatch.findLiveMatch.do") parameters:[self requestPrameters] success:success failure:failure];
}

+ (void)requestScheduledMatchSuccess:(PPHttpRequestSuccess)success
                             failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:kRequestPath(@"basketballMatch.findScheduledMatch.do") parameters:[self requestPrameters] success:success failure:failure];
}


/**
 查询实时比分

 @param matchId 比赛id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestMatchScore:(NSString *)matchId
                  success:(PPHttpRequestSuccess)success
                  failure:(PPHttpRequestFailed)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self requestPrameters]];
    [params setObject:matchId forKey:@"thirdId"];
    [PPNetworkHelper GET:kRequestPath(@"IOSBasketballDetail.findScore.do") parameters:params success:success failure:failure];
}


/**
 查询实时盘口

 @param matchId 比赛id
 @param oddsType 盘口类型
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestMatchOdds:(NSString *)matchId
                oddsType:(int)oddsType
                  success:(PPHttpRequestSuccess)success
                  failure:(PPHttpRequestFailed)failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self requestPrameters]];
    
    NSString *oddsTypeStr = @"asiaLet";
    if (oddsType == 1) {
        oddsTypeStr = @"asiaSize";
    }
    if(oddsType == 2) {
        oddsTypeStr = @"euro";
    }
    [params setObject:oddsTypeStr forKey:@"oddsType"];
    [params setObject:matchId forKey:@"thirdId"];
    
    [PPNetworkHelper GET:kRequestPath(@"basketballDetail.findOdds.do") parameters:params success:success failure:failure];
}


/*
 // 查询比赛比分
http://m.13322.com/mlottery/core/IOSBasketballDetail.findScore.do?_=1523890935.918744&appType=1&appno=11&deviceId=5BAD9C8825214AB782C7D0B7216F5454&deviceToken=&lang=zh&loginToken=&sign=ecdb94b8b7c4ff74841b282a9103c22f32&thirdId=7450487&timeZone=8&userId=&version=240
 
 // 最新盘口
 http://m.13322.com/mlottery/core/basketballDetail.findOdds.do?_=5&appType=1&appno=11&deviceId=5BAD9C8825214AB782C7D0B7216F5454&deviceToken=&lang=zh&loginToken=&oddsType=asiaSize&sign=5994bbb50634604239975a032dc0e3346a&thirdId=7447737&timeZone=8&userId=&version=240
 
 // 新盘口和初盘(让分） 新的在前 初盘在后
 // http://m.13322.com/mlottery/core/basketballDetail.findOdds.do?_=1523891423.113843&appType=1&appno=11&deviceId=5BAD9C8825214AB782C7D0B7216F5454&deviceToken=&lang=zh&loginToken=&oddsType=asiaLet&sign=b07139c8dd2bb957a97216d4e5e09dbee6&thirdId=7449997&timeZone=8&userId=&version=240
 
 // 胜负
 http://m.13322.com/mlottery/core/basketballDetail.findOdds.do?_=1523891597.283983&appType=1&appno=11&deviceId=5BAD9C8825214AB782C7D0B7216F5454&deviceToken=&lang=zh&loginToken=&oddsType=euro&sign=ee8ccb96441fe1a3efa56456354cf2d16e&thirdId=7449997&timeZone=8&userId=&version=240
 
 // 大小分
 http://m.13322.com/mlottery/core/basketballDetail.findOdds.do?_=1523891727.712246&appType=1&appno=11&deviceId=5BAD9C8825214AB782C7D0B7216F5454&deviceToken=&lang=zh&loginToken=&oddsType=asiaSize&sign=933e56edda3a93ed7129c305d3d5cd797c&thirdId=7449997&timeZone=8&userId=&version=240
 
*/

+ (NSDictionary *)requestPrameters {
    NSString *dateString = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    return @{
             @"version": @"240",
             @"userId": @"",
             @"timeZone": @"8",
             @"sign": [dateString md2String].lowercaseString,
             @"loginToken": @"",
             @"lang": @"zh",
             @"deviceToken": @"",
             @"deviceId": [dateString md5String].uppercaseString,
             @"appno": @"11",
             @"appType": @"1",
             @"_": dateString
             };
}


@end
