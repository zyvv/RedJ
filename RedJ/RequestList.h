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

@end
