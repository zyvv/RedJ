//
//  Order.m
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "Order.h"

@implementation Order

@end


@implementation Bet

- (NSString *)betId {
    NSDictionary *dict = @{@"orderUserName": self.orderUserName,
                           @"matchId": self.matchId,
                           @"betOdds": @(self.betOdds),
                           @"leftOdds": @(self.leftOdds),
                           @"betType": @(self.betType),
                           @"handicapValue": @(self.handicapValue),
                           @"leftOddsValue": @(self.leftOddsValue),
                           @"rightOddsValue": @(self.rightOddsValue)
                           };
    return [[dict jsonStringEncoded] md2String];
}

- (NSDate *)getCLupdatedAt {
    if (self.updatedAt) {
        if (self.updatedAt[@"iso"]) {
            return [self dateFromISO8601String:self.updatedAt[@"iso"]];
        }
    }
    return nil;
}

- (NSDate *)dateFromISO8601String:(NSString *)string {
    if (!string) return nil;
    struct tm tm;
    time_t t;
    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];//东八区
}

- (AVObject *)betModelToAVObj {
    NSDictionary *jsonDict = [self yy_modelToJSONObject];
    return [AVObject objectWithDictionary:jsonDict];
}

- (void)bet:(Account *)account betBlock:(betBlock)betBlock {
    if (!account) {
        __weak Bet *weakSelf = self;
        [User currentUserAccount:^(Account *ac, NSError *error) {
            if (ac) {
                [weakSelf bet:ac betBlock:betBlock];
            } else {
                betBlock(NO, NO, account, nil);
            }
        }];
    }
    
    BOOL appendBet = NO;
    AVQuery *query = [AVQuery queryWithClassName:@"Bet"];
    [query whereKey:@"betId" equalTo:self.betId];
    AVObject *obj = [query getFirstObject];
    AVObject *betObj;
    if (obj) {
        appendBet = YES;
        betObj = [AVObject objectWithClassName:@"Bet" objectId:obj.objectId];
        [betObj incrementKey:@"betAmount" byAmount:@(self.betAmount)];
        [betObj incrementKey:@"appendCount"];
    } else {
        betObj = [AVObject objectWithClassName:@"Bet" dictionary:[self yy_modelToJSONObject]];
    }
    
    AVObject *accObj = [AVObject objectWithClassName:@"Account" objectId:account.objectId];
    accObj.fetchWhenSave = YES;
    [accObj setObject:@(account.balance - self.betAmount) forKey:@"balance"];
    
    
    AVObject *userBetMapTom = [[AVObject alloc] initWithClassName:@"UserBet"];// 用户投注
    [userBetMapTom setObject:[AVUser currentUser] forKey:@"user"];
    [userBetMapTom setObject:betObj forKey:@"bet"];
    [userBetMapTom setObject:accObj forKey:@"userAccount"];
    userBetMapTom.fetchWhenSave = YES;
    [userBetMapTom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (betBlock) {
            if (succeeded) {
                account.balance = account.balance - self.betAmount;
            }
            betBlock(succeeded, appendBet, account, error);
        }
    }];
}

@end
