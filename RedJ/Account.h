//
//  Account.h
//  RedJ
//
//  Created by vi~ on 2018/4/14.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject
@property (nonatomic, copy) NSString *objectId; // 存储id
@property (nonatomic, assign) float totalAccount; // 账户总额
@property (nonatomic, assign) float balance; // 账户余额
@end
