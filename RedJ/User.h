//
//  User.h
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

typedef void (^UserAccountBlock)(Account *account, NSError *error);

@interface User : NSObject

+ (User *)currentUser;

+ (void)currentUserAccount:(UserAccountBlock)userAccountBlock;

@property (nonatomic, copy) NSString *objectId; // 存储id
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
//@property (nonatomic, strong) Account *account;

@end
