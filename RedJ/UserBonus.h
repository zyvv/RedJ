//
//  UserBonus.h
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/20.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBonus : NSObject

@property (nonatomic, strong) NSDate *bonusBeginTime;
@property (nonatomic, strong) NSDate *bonusEndTime;
@property (nonatomic, assign) float bonusAmount;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, assign) BOOL received;
@property (nonatomic, assign) BOOL overdue;
@property (nonatomic, copy) NSString *bonusName;
@property (nonatomic, copy) NSString *emojiTitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *bonusDes;


+ (void)haveUserBonus:(void(^)(UserBonus *bonus))bonusBlock;

+ (void)receiveBonus:(UserBonus *)bonus success:(void(^)(BOOL success))successBlock;

@end
