//
//  UserBonus.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/20.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "UserBonus.h"
#import "User.h"

@implementation UserBonus

+ (void)haveUserBonus:(void(^)(UserBonus *bonus))bonusBlock {
    if (![AVUser currentUser]) {
        return;
    }
    AVQuery *query = [AVQuery queryWithClassName:@"Bonus"];
    [query whereKey:@"overdue" equalTo:@(NO)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            for (AVObject *obj in objects) {
                UserBonus *bonus = [UserBonus yy_modelWithJSON:[obj dictionaryForObject]];
                AVQuery *query1 = [AVQuery queryWithClassName:@"UserBonus"];
                [query1 whereKey:@"username" equalTo:[User currentUser].username];
                AVQuery *query2 = [AVQuery queryWithClassName:@"UserBonus"];
                [query2 whereKey:@"bonusName" equalTo:[obj objectForKey:@"bonusName"]];
                AVQuery *query = [AVQuery andQueryWithSubqueries:@[query1, query2]];
                [query getFirstObjectInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
                    if (object) {
                        if (bonusBlock) {
                            bonusBlock(nil);
                        }
                    } else {
                        if (bonusBlock) {
                            bonusBlock(bonus);
                        }
                    }
                }];
            }

        }
    }];
}

+ (void)receiveBonus:(UserBonus *)bonus success:(void (^)(BOOL success))successBlock {
    [User currentUserAccount:^(Account *ac, NSError *error) {
        if (ac) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                AVObject *accObj = [AVObject objectWithClassName:@"Account" objectId:ac.objectId];
                [accObj incrementKey:@"totalAccount" byAmount:@(bonus.bonusAmount)];
                [accObj incrementKey:@"balance" byAmount:@(bonus.bonusAmount)];

                [accObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        AVObject *obj = [AVObject objectWithClassName:@"UserBonus"];
                        [obj setObject:[User currentUser].username forKey:@"username"];
                        [obj setObject:@(bonus.bonusAmount) forKey:@"bonusAmount"];
                        [obj setObject:@(YES) forKey:@"received"];
                        [obj setObject:bonus.bonusName forKey:@"bonusName"];
                        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (successBlock) {
                                successBlock(succeeded);
                            }
                        }];
                    } else {
                        if (successBlock) {
                            successBlock(NO);
                        }
                    }
                }];
            });
        } else {
            if (successBlock) {
                successBlock(NO);
            }
        }
    }];
}

@end
