//
//  BetHeaderView.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetHeaderView.h"

@interface BetHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *guestLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *guestLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchScoreLabel;

@end

@implementation BetHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setMatch:(Match *)match {
    if (_match != match) {
        _match = match;
    }
    [self setNeedsLayout];
}

- (void)setAccount:(Account *)account {
    if (_account != account) {
        _account = account;
    }
    [self setNeedsLayout];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_guestLogoImageView yy_setImageWithURL:_match.guestLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    [_homeLogoImageView yy_setImageWithURL:_match.homeLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    
    _guestLabel.text = [NSString stringWithFormat:@"(客)%@",  _match.guestTeam];
    _homeLabel.text = [NSString stringWithFormat:@"(主)%@",  _match.homeTeam];
    
    if (_match.matchStatus == -1) {
        _statusLabel.text = @"已结束";
    } else if (_match.matchStatus != 0) {
        _statusLabel.text = @"正在进行中";
    } else {
        _statusLabel.text = @"未开始";
    }
    
    _matchScoreLabel.text = [NSString stringWithFormat:@"%.0f : %.0f", _match.matchScore.guestScore, _match.matchScore.homeScore];
    _balanceLabel.text = [NSString stringWithFormat:@"账户余额：%.2f", _account.balance];
}

@end
