//
//  RankingCell.m
//  RedJ
//
//  Created by vi~ on 2018/4/15.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "RankingCell.h"
#import "UserSettle.h"

@implementation RankingCell
{
    __weak IBOutlet UILabel *_usernameLabel;
    __weak IBOutlet UILabel *_totalAmountLabel;
    __weak IBOutlet UILabel *_yesterdayEarningLabel;
    __weak IBOutlet UILabel *_rankingLabel;
    __weak IBOutlet UILabel *_todayPayLabel;
    __weak IBOutlet UILabel *_recordLabel;
    __weak IBOutlet UILabel *_earningDayLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUserRanking:(Ranking *)userRanking {
    if (_userRanking != userRanking) {
        _userRanking = userRanking;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _earningDayLabel.text = @"今日实时收益";
    _usernameLabel.text = _userRanking.userName;
    _rankingLabel.text = [NSString stringWithFormat:@"# %d", _ranking];
    _yesterdayEarningLabel.text = [NSString stringWithFormat:@"%.2f", _userRanking.totalEarning];
    _recordLabel.text = [NSString stringWithFormat:@"%d红%d黑", _userRanking.hong, _userRanking.hei];
    _todayPayLabel.text = [NSString stringWithFormat:@" (未结算:%.2f)", _userRanking.todayPay];
    _totalAmountLabel.text = [NSString stringWithFormat:@"%.2f", _userRanking.totalAccount - _userRanking.todayPay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
