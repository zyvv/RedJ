//
//  Match.m
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "Match.h"

@implementation Pankou

@end

@implementation AsiaLet

@end

@implementation AsiaSize

@end

@implementation MatchOdds

@end

@implementation Match

@end

@implementation MatchData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"match" : [Match class]};
}
@end

@implementation ResponseModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"matchData" : [MatchData class]};
}
@end

@implementation Game

@end
