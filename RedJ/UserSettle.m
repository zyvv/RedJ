//
//  UserSettle.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "UserSettle.h"
#import "User.h"
#import "RequestList.h"
#import "Order.h"
#import "Match.h"

@implementation UserSettle

+ (void)settleAndUploadTodayEarning {
    if (![AVUser currentUser]) {
        return;
    }
    if (![[self class] isSettleTime]) {
        return;
    }
    NSString *rankedFlag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Ranked_%@",[User currentUser].username]];
    if (rankedFlag && [rankedFlag isEqualToString:[[self class] formatToday]]) {
        return;
    }
    AVQuery *query1 = [AVQuery queryWithClassName:@"BetRanked"];
    [query1 whereKey:@"userName" equalTo:[User currentUser].username];
    AVQuery *query2 = [AVQuery queryWithClassName:@"BetRanked"];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *nowStr = [dateFormat stringFromDate:now];
    [query2 whereKey:@"rankedDay" equalTo:nowStr];
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if (!object) {
            [[self class] needPanDian];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[[self class] formatToday] forKey:[NSString stringWithFormat:@"Ranked_%@",[User currentUser].username]];
        }
    }];
}

+ (void)needPanDian {
    [RequestList requestRankingMatch:^(id responseObject) {
        
        AVQuery *query1 = [AVQuery queryWithClassName:@"Bet"];
        [query1 whereKey:@"orderUserName" equalTo:[User currentUser].username];
        AVQuery *query2 = [AVQuery queryWithClassName:@"Bet"];
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *nowStr = [dateFormat stringFromDate:now];
        [query2 whereKey:@"matchDate" equalTo:nowStr];
        AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if (results) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AVObject *obj in results) {
                    NSMutableDictionary *dict = [obj dictionaryForObject];
                    [tempArray addObject:dict];
                }
                NSArray *betsArray = [NSArray yy_modelArrayWithClass:[Bet class] json:tempArray];
                [[self class] pandian:responseObject betsArray:betsArray];
            }
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

+ (void)pandian:(NSArray *)matchsArray betsArray:(NSArray *)betsArray {
    if (!matchsArray || !betsArray) {
        return;
    }
    NSMutableArray *settledBetsArray = [NSMutableArray arrayWithCapacity:0];
    CGFloat totalEarning = 0;
    int hong = 0;
    int hei = 0;
    int totalEarningWithoutBenJin = 0;
    for (Bet *bet in betsArray) {
        for (Match *match in matchsArray) {
            if ([bet.matchId isEqualToString:match.thirdId]) {
                AVObject *obj = [AVObject objectWithClassName:@"Bet" objectId:bet.objectId];
                [obj setObject:@(YES) forKey:@"settle"];
                [obj setObject:[NSDate date] forKey:@"settleDate"];
                [obj setObject:[match yy_modelToJSONObject] forKey:@"match"];
                //                bet.match = match;
                //                bet.settle = YES;
                //                bet.settleDate = [NSDate date];
                CGFloat betOdds = round(bet.betOdds * 100) / 100;
                if (bet.betType == 1) { // 大小分
                    CGFloat size = match.matchScore.guestScore + match.matchScore.homeScore;
                    CGFloat handicapValue = bet.handicapValue;
                    if (handicapValue == 0) {
                        handicapValue = bet.match.matchOdds.asiaSize.bet365.handicapValue;
                    }
                    if (handicapValue == size) {
                        bet.earnings = bet.betAmount;
                        [obj setObject:@(bet.betAmount) forKey:@"earnings"];
                    } else {
                        BOOL sizeLeft ;
                        if (handicapValue < size) { // 大分
                            sizeLeft = YES;
                        } else { // 小分
                            sizeLeft = NO;
                        }
                        bet.earnings = (1 + betOdds) * bet.betAmount;
                        //                        bet.status = 1;
                        [obj setObject:@((1 + betOdds) * bet.betAmount) forKey:@"earnings"];
                        [obj setObject:@(1) forKey:@"status"];
                        if (bet.leftOdds != sizeLeft) {
                            // 黑
                            bet.earnings = -(bet.betAmount);
                            //                            bet.status = -1;
                            [obj setObject:@(-bet.betAmount) forKey:@"earnings"];
                            [obj setObject:@(-1) forKey:@"status"];
                            hei++;
                        } else {
                            hong++;
                        }
                    }
                } else if (bet.betType == 0) { // 让分
                    CGFloat let = match.matchScore.homeScore - match.matchScore.guestScore;
                    CGFloat handicapValue = bet.handicapValue;
                    if (handicapValue == 0) {
                        handicapValue = bet.match.matchOdds.asiaLet.bet365.handicapValue;
                    }
                    if (handicapValue == let) {
                        bet.earnings = bet.betAmount;
                        [obj setObject:@(bet.betAmount) forKey:@"earnings"];
                    } else {
                        BOOL letLeft;
                        if (handicapValue < let) {
                            letLeft = NO;
                        } else {
                            letLeft = YES;
                        }
                        bet.earnings = (1 + betOdds) * bet.betAmount;
                        //                        bet.status = 1;
                        [obj setObject:@((1 + betOdds) * bet.betAmount) forKey:@"earnings"];
                        [obj setObject:@(1) forKey:@"status"];
                        if (bet.leftOdds != letLeft) {
                            // 黑
                            bet.earnings = -(bet.betAmount);
                            //                            bet.status = -1;
                            [obj setObject:@(-bet.betAmount) forKey:@"earnings"];
                            [obj setObject:@(-1) forKey:@"status"];
                            hei++;
                        } else {
                            hong++;
                        }
                    }
                } else { //  胜负
                    if (match.matchScore.guestScore == match.matchScore.homeScore) {
                        bet.earnings = bet.betAmount;
                        [obj setObject:@(bet.betAmount) forKey:@"earnings"];
                    }
                    BOOL guestWin = match.matchScore.guestScore > match.matchScore.homeScore;
                    bet.earnings = (1 + betOdds) * bet.betAmount;
                    //                        bet.status = 1;
                    [obj setObject:@((1 + betOdds) * bet.betAmount) forKey:@"earnings"];
                    [obj setObject:@(1) forKey:@"status"];
                    if (bet.leftOdds != guestWin) {
                        // 黑
                        bet.earnings = -(bet.betAmount);
                        //                            bet.status = -1;
                        [obj setObject:@(-bet.betAmount) forKey:@"earnings"];
                        [obj setObject:@(-1) forKey:@"status"];
                        hei++;
                    } else {
                        hong++;
                    }
                }
                
                if (bet.earnings > 0) {
                    totalEarningWithoutBenJin += (bet.earnings - bet.betAmount);
                    totalEarning += bet.earnings;
                } else {
                    totalEarningWithoutBenJin += (bet.earnings);
                }
                
                [settledBetsArray addObject:obj];
            }
        }
    }
    [User currentUserAccount:^(Account *ac, NSError *error) {
        if (ac) {
            
            CGFloat totalAccount = ac.totalAccount + totalEarningWithoutBenJin;
            CGFloat balance = ac.balance + totalEarning;
            
            AVObject *accObj = [AVObject objectWithClassName:@"Account" objectId:ac.objectId];
            [accObj setObject:@(totalAccount) forKey:@"totalAccount"];
            [accObj setObject:@(balance) forKey:@"balance"];
            [settledBetsArray addObject:accObj];
            
            NSError *error = nil;
            [AVObject saveAll:settledBetsArray error:&error];
            
            if (!error) {
                AVObject *obj = [AVObject objectWithClassName:@"BetRanked"];
                [obj setObject:[User currentUser].username forKey:@"userName"];
                NSDate *now = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                NSString *nowStr = [dateFormat stringFromDate:now];
                [obj setObject:nowStr forKey:@"rankedDay"];
                [obj setObject:@(hong) forKey:@"hong"];
                [obj setObject:@(hei) forKey:@"hei"];
                [obj setObject:@(totalEarningWithoutBenJin) forKey:@"totalEarning"];
                [obj setObject:@(totalAccount) forKey:@"totalAccount"];
                [obj setObject:@(totalAccount - balance) forKey:@"todayPay"];
                
                AVObject *userBetMapTom = [[AVObject alloc] initWithClassName:@"UserRanked"];// 用户投注
                [userBetMapTom setObject:[AVUser currentUser] forKey:@"user"];
                [userBetMapTom setObject:obj forKey:@"ranked"];
                userBetMapTom.fetchWhenSave = YES;
                [userBetMapTom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [[NSUserDefaults standardUserDefaults] setObject:[[self class] formatToday] forKey:[NSString stringWithFormat:@"Ranked_%@",[User currentUser].username]];
                    }
                }];
            }
        }
    }];
}

+ (BOOL)isRankingDuration {
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    
    NSString *nowStr = [dateFormat stringFromDate:now];
    now = [dateFormat dateFromString:nowStr];
    
    NSDate *rankingTime = [dateFormat dateFromString:@"15:00"];
    
    if ([now compare:rankingTime] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

+ (NSString *)formatToday {
    static NSString *formatToday = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        formatToday = [dateFormat stringFromDate:now];
    });
    return formatToday;
}

+ (BOOL)isSettleTime {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    
    NSString *nowStr = [dateFormat stringFromDate:now];
    now = [dateFormat dateFromString:nowStr];
    
    NSDate *rankingTime = [dateFormat dateFromString:@"15:00"];
    NSDate *rankingStopTime = [dateFormat dateFromString:@"23:50"];
    
    if ([now compare:rankingTime] == NSOrderedDescending && [now compare:rankingStopTime] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}


@end
