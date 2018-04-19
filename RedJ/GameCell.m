//
//  GameCell.m
//  RedJ
//
//  Created by vi~ on 2018/4/13.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "GameCell.h"

@implementation GameCell
{
    __weak IBOutlet UIView *_statusView;
    __weak IBOutlet UIImageView *_guestLogoImageView;
    __weak IBOutlet UIImageView *_homeLogoImageView;
    
    __weak IBOutlet UILabel *_guestTeamLabel;
    __weak IBOutlet UILabel *_homeTeamLabel;

    __weak IBOutlet UILabel *_guestLet;
    __weak IBOutlet UILabel *_homeLet;
    
    __weak IBOutlet UILabel *_homeLetOdds;
    __weak IBOutlet UILabel *_guestLetOdds;
    
    __weak IBOutlet UILabel *_bigSize;
    __weak IBOutlet UILabel *_smallSize;
    
    __weak IBOutlet UILabel *_bigOdds;
    __weak IBOutlet UILabel *_smallOdds;
    
    __weak IBOutlet UILabel *_leagueLabel;
    
    __weak IBOutlet UILabel *_matchTimeLabel;
    __weak IBOutlet UILabel *_statusLabel;
    __weak IBOutlet UILabel *_guestScoreLabel;
    __weak IBOutlet UILabel *_homeScoreLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    _bigOdds.layer.masksToBounds = _smallOdds.layer.masksToBounds = _homeLetOdds.layer.masksToBounds = _guestLetOdds.layer.masksToBounds = YES;
//    _bigOdds.layer.borderColor = _smallOdds.layer.borderColor = _homeLetOdds.layer.borderColor = _guestLetOdds.layer.borderColor = [UIColor blackColor].CGColor;
//    _bigOdds.layer.borderWidth = _smallOdds.layer.borderWidth = _homeLetOdds.layer.borderWidth = _guestLetOdds.layer.borderWidth = 2;
//    _bigOdds.layer.cornerRadius = _smallOdds.layer.cornerRadius = _homeLetOdds.layer.cornerRadius = _guestLetOdds.layer.cornerRadius = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMatch:(Match *)match {
    if (_match != match) {
        _match = match;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_guestLogoImageView yy_setImageWithURL:_match.guestLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    [_homeLogoImageView yy_setImageWithURL:_match.homeLogoUrl options:YYWebImageOptionSetImageWithFadeAnimation];
    _guestTeamLabel.text = _match.guestTeam;
    _homeTeamLabel.text = _match.homeTeam;
    _matchTimeLabel.text = _match.time;
    _leagueLabel.text = _match.leagueName;
    
    _guestScoreLabel.text = [NSString stringWithFormat:@"%.0f", _match.matchScore.guestScore];
    _homeScoreLabel.text = [NSString stringWithFormat:@"%.0f", _match.matchScore.homeScore];
    
    
    
//    float handicapValue = _match.matchOdds.asiaLet.bet365.handicapValue;
//    if (handicapValue >= 0) {
//        _guestLet.text = [NSString stringWithFormat:@"+%.1f", handicapValue];
//        _homeLet.text = [NSString stringWithFormat:@"-%.1f", handicapValue];
//    } else {
//        _guestLet.text = [NSString stringWithFormat:@"%.1f", handicapValue];
//        _homeLet.text = [NSString stringWithFormat:@"+%.1f", -handicapValue];
//    }
//    _guestLetOdds.text = [NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.leftOdds];
//    _homeLetOdds.text = [NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaLet.bet365.rightOdds];
//
//    _bigSize.text = [NSString stringWithFormat:@"大%.1f", _match.matchOdds.asiaSize.bet365.handicapValue];
//    _smallSize.text = [NSString stringWithFormat:@"小%.1f", _match.matchOdds.asiaSize.bet365.handicapValue];
//
//    _bigOdds.text = [NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.leftOdds];
//    _smallOdds.text = [NSString stringWithFormat:@"%.2f", _match.matchOdds.asiaSize.bet365.rightOdds];
    
    if (_match.matchStatus == -1) {
        _statusLabel.text = @"完场";
        _statusLabel.textColor = [UIColor lightGrayColor];
    } else if (_match.matchStatus == 0) {
        _statusLabel.text = @"未开";
        _statusLabel.textColor = [UIColor lightGrayColor];
    } else {
        _statusLabel.text = [NSString stringWithFormat:@"%d节 %@", _match.section, _match.matchScore.remainTime];
        _statusLabel.textColor = [UIColor greenColor];
    }
    
}

@end
