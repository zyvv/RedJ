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

+ (void)requestMatch:(NSInteger)matchType
             success:(PPHttpRequestSuccess)success
             failure:(PPHttpRequestFailed)failure {
    
    NSString *path = nil;
    if (matchType == 0) {
        path = @"basketballMatch.findLiveMatch.do";
    }
    if (matchType == 1) {
        path = @"basketballMatch.findFinishedMatch.do";
    }
    if (matchType == 2) {
        path = @"basketballMatch.findScheduledMatch.do";
    }
    
     NSArray *(^handleResponseObject)(id responseObject) = ^(id responseObject) {
        ResponseModel *finishedModel = [ResponseModel yy_modelWithJSON:responseObject];
        NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:0];
        if (finishedModel.result == 200) {
            for (MatchData *matchData in finishedModel.matchData) {
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
        return responseArray;
    };
    PPHttpRequestFailed failedBlock = ^(NSError *error) {
        if ([[self class] cacheForKey:path]) {
            success(handleResponseObject([[self class] cacheForKey:path]));
        } else {
            if (error) {
                failure(error);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:-100 userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
                failure(error);
            }
        }
    };
    PPHttpRequestSuccess successBlock = ^(id responseObject) {
//        [[self class] setCache:responseObject forKey:path];
        success(handleResponseObject(responseObject));
    };

    if (success) {
        success(handleResponseObject([[self class] cacheForKey:path]));
    }
    [PPNetworkHelper GET:kRequestPath(path) parameters:[self requestPrameters] success:successBlock failure:failedBlock];
}

+ (void)requestFinishedMatchSuccess:(PPHttpRequestSuccess)success
                            failure:(PPHttpRequestFailed)failure {
    [PPNetworkHelper GET:kRequestPath(@"basketballMatch.findFinishedMatch.do") parameters:[self requestPrameters] success:^(id responseObject) {
        ResponseModel *finishedModel = [ResponseModel yy_modelWithJSON:responseObject];
        if (finishedModel.result == 200) {
            NSMutableArray *matchs = [NSMutableArray arrayWithCapacity:0];
            for (MatchData *matchData in finishedModel.matchData) {
                for (Match *match in matchData.match) {
                    if ([match.leagueId isEqualToString:@"1"] || [match.leagueId isEqualToString:@"5"]) {
                        [matchs addObject:match];
                    }
                }
            }
            success([matchs copy]);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"com.zyvv.error" code:finishedModel.result userInfo:@{NSLocalizedDescriptionKey: @"返回数据错误"}];
            failure(error);
        }

    } failure:failure];
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

+ (void)setCache:(id)object forKey:(NSString *)pathKey  {
    YYCache *cache = [YYCache cacheWithName:@"RedJCache"];
    [cache setObject:object forKey:pathKey];
}

+ (id)cacheForKey:(NSString *)pathKey {
    YYCache *cache = [YYCache cacheWithName:@"RedJCache"];
    return [cache objectForKey:pathKey];
}

@end
