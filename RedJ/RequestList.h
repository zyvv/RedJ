//
//  RequestList.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestList : NSObject

+ (void)requestMatchSuccess:(PPHttpRequestSuccess)success
                    failure:(PPHttpRequestFailed)failure;

+ (void)requestRankingMatch:(PPHttpRequestSuccess)success
                   failure:(PPHttpRequestFailed)failure;

/**
 查询实时比分
 
 @param matchId 比赛id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)requestMatchScore:(NSString *)matchId
                  success:(PPHttpRequestSuccess)success
                  failure:(PPHttpRequestFailed)failure;


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
                 failure:(PPHttpRequestFailed)failure;

@end
