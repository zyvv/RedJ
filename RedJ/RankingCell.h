//
//  RankingCell.h
//  RedJ
//
//  Created by vi~ on 2018/4/15.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ranking.h"

@interface RankingCell : UITableViewCell

@property (nonatomic, strong) UserRanking *userRanking;
@property (nonatomic, assign) int ranking;

@end
