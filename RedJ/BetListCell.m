//
//  BetListCell.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/17.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetListCell.h"

@interface BetListCell ()

@property (weak, nonatomic) IBOutlet UILabel *appendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *betAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *earningLabel;
@property (weak, nonatomic) IBOutlet UILabel *betValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *betOddsLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;

@end

@implementation BetListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBet:(Bet *)bet {
    if (_bet != bet) {
        _bet = bet;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_bet.appendCount > 0) {
        _appendCountLabel.text = [NSString stringWithFormat:@"+%d", _bet.appendCount];
    }
    _betAmountLabel.text = [NSString stringWithFormat:@"%.2f", _bet.betAmount];
    if (_bet.settle) {
        if (_bet.earnings == _bet.betAmount) {
            _earningLabel.text = @"水单";
        } else {
            _earningLabel.text = _bet.earnings > _bet.betAmount ? [NSString stringWithFormat:@"盈 +%.2f", (_bet.earnings - _bet.betAmount)] : [NSString stringWithFormat:@"亏 %.2f", -_bet.betAmount];
        }
    } else {
        _earningLabel.text = @"未结算";
    }
    
    if (_bet.betType == 0) { // 让分
        _betValueLabel.text = _bet.leftOdds ? [NSString stringWithFormat:@"%@ %@", _bet.match.guestTeam, [self fuhao:_bet.handicapValue]] : [NSString stringWithFormat:@"%@ %@", _bet.match.homeTeam, [self fuhao:-(_bet.handicapValue)]];
    }
    if (_bet.betType == 1) { // 大小分
        _betValueLabel.text = _bet.leftOdds ? [NSString stringWithFormat:@"大 %@", [self fuhao:_bet.handicapValue]] : [NSString stringWithFormat:@"小 %@", [self fuhao:_bet.handicapValue]];
    }
    if (_bet.betType == 2) { // 胜负
        _betValueLabel.text = _bet.leftOdds ? [NSString stringWithFormat:@"%@ 胜", _bet.match.guestTeam] : [NSString stringWithFormat:@"%@ 胜", _bet.match.homeTeam];
    }

    if (_bet.leftOddsValue == 0 || _bet.rightOddsValue == 0) {
        _betOddsLabel.text = @"未知赔率";
    } else {
        _betOddsLabel.text = _bet.leftOdds ? [NSString stringWithFormat:@"%.2f", _bet.leftOddsValue] : [NSString stringWithFormat:@"%.2f", _bet.rightOddsValue];
    }
    
    
    _creatDateLabel.text = [NSString stringWithFormat:@"下注时间：%@", [self formatDate:_bet.betDate]];
    _updateDateLabel.text = [NSString stringWithFormat:@"最后更新：%@", [self formatDate:[_bet getCLupdatedAt]]];

}

- (NSString *)fuhao:(float)num {
    if (num > 0) {
        return [NSString stringWithFormat:@"+%.1f", num];
    }
    return [NSString stringWithFormat:@"%.1f", num];
}

- (NSString *)formatDate:(NSDate *)date {

    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM月dd日 HH:mm";
    });
    return [formatter stringFromDate:date];
}

@end
