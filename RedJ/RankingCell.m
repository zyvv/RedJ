//
//  RankingCell.m
//  RedJ
//
//  Created by vi~ on 2018/4/15.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "RankingCell.h"

@implementation RankingCell
{
    __weak IBOutlet UILabel *_usernameLabel;
    __weak IBOutlet UILabel *_totalAmountLabel;
    __weak IBOutlet UILabel *_yesterdayEarningLabel;
    __weak IBOutlet UILabel *_rankingLabel;
    __weak IBOutlet UILabel *_todayPayLabel;
    __weak IBOutlet UILabel *_recordLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUserRanking:(UserRanking *)userRanking {
    if (_userRanking != userRanking) {
        _userRanking = userRanking;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _usernameLabel.text = _userRanking.userName;
//    _totalAmountLabel.text =
    _yesterdayEarningLabel.text = [NSString stringWithFormat:@"%.2f", _userRanking.todayEarning];
    _recordLabel.text = [NSString stringWithFormat:@"%d红%d黑", _userRanking.hong, _userRanking.hei];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
