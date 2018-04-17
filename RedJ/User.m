//
//  User.m
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "User.h"

@implementation User

+ (User *)currentUser {
    static dispatch_once_t onceToken;
    static User *user = nil;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *userDict = [[AVUser currentUser] dictionaryForObject];
        user = [User yy_modelWithJSON:userDict];
    });
    if (user == nil) {
        NSMutableDictionary *userDict = [[AVUser currentUser] dictionaryForObject];
        user = [User yy_modelWithJSON:userDict];
    }
    return user;
}

+ (void)currentUserAccount:(UserAccountBlock)userAccountBlock {
    AVQuery *accountQuery = [AVQuery queryWithClassName:@"Account"];
    [accountQuery whereKey:@"username" equalTo:[AVUser currentUser].username];
    [accountQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        Account *account = nil;
        if (results.count > 0) {
            AVObject *accountObj = results.lastObject;
            NSMutableDictionary *accountDict = [accountObj dictionaryForObject];
            account = [Account yy_modelWithJSON:accountDict];
        }
        if (userAccountBlock) {
            userAccountBlock(account, error);
        }

    }];
}

@end
