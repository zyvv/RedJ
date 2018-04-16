//
//  RequestList.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "RequestList.h"
#import "Match.h"


@implementation RequestList

+ (void)requestMatchSuccess:(PPHttpRequestSuccess)success
                    failure:(PPHttpRequestFailed)failure {
    [RequestList requestLiveMatchSuccess:^(id responseObject) {
        ResponseModel *liveModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (liveModel.result == 200) {
            [self requestScheduledMatchSuccess:^(id responseObject) {
                ResponseModel *scheduledModel = [ResponseModel yy_modelWithJSON:responseObject];
                if (scheduledModel.result == 200) {
                    NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:0];
                    
                    for (MatchData *matchData in liveModel.matchData) {
                        if (matchData.diffDays == 0) { // 正在进行的比赛
                            Game *game = [Game new];
                            game.date = matchData.date;
                            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                            for (Match *match in matchData.match) {
                                if ([match.leagueId isEqualToString:@"1"]) {
                                    [matchs addObject:match];
                                }
                            }
                            game.matchs = matchs;
                            if (matchs.count > 0) {
                                [responseArray addObject:game];
                            }
                        }
                        
                        if (matchData.diffDays == 1) { // 明日比赛
                            Game *game = [Game new];
                            game.date = matchData.date;
                            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
                            for (Match *match in matchData.match) {
                                if ([match.leagueId isEqualToString:@"1"]) {
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
                                if ([match.leagueId isEqualToString:@"1"]) {
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

+ (void)requestFinishedMatchSuccess:(PPHttpRequestSuccess)success
                            failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findFinishedMatch.do" parameters:[self requestPrameters] success:success failure:failure];
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
                        if ([match.leagueId isEqualToString:@"1"]) {
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
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findLiveMatch.do" parameters:[self requestPrameters] success:success failure:failure];
}

+ (void)requestScheduledMatchSuccess:(PPHttpRequestSuccess)success
                             failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:@"http://m.13322.com/mlottery/core/basketballMatch.findScheduledMatch.do" parameters:[self requestPrameters] success:success failure:failure];
}

+ (NSDictionary *)requestPrameters {
    return @{
             @"version": @"240",
             @"userId": @"",
             @"timeZone": @"8",
             @"sign": @"48fb6a2abcba80554892266fc6398649fb",
             @"loginToken": @"",
             @"lang": @"zh",
             @"deviceToken": @"",
             @"deviceId": @"5BAD9C8825214AB782C7D0B7216F5454",
             @"appno": @"11",
             @"appType": @"1",
             @"_": [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]]
             };
}


@end
