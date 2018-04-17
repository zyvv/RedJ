//
//  BetCell.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetCell.h"

@interface BetCell ()
@property (weak, nonatomic) IBOutlet UIView *updateStausView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *guestValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeValueLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *oddsSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *amountSegment;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (assign, nonatomic) BOOL hasUpdate;
@end

@implementation BetCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5;
    self.updateStausView.layer.masksToBounds = YES;
    self.updateStausView.layer.cornerRadius = 2;
    
    self.amountSegment.selectedSegmentIndex = 0;
    self.oddsSegment.selectedSegmentIndex = 0;
    
    self.betEable = NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.amountSegment.selectedSegmentIndex = 0;
    self.oddsSegment.selectedSegmentIndex = 0;
    
    self.betEable = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.hasUpdate) {
        self.updateStausView.backgroundColor = [UIColor greenColor];
    } else {
        self.updateStausView.backgroundColor = [UIColor clearColor];
    }
    
    if (self.betType == 0) {
        self.titleLabel.text = @"让分";
        self.guestValueLabel.text = [NSString stringWithFormat:@"%@ %@", _match.guestTeam, [self fuhao:_pankou.handicapValue]];
        self.homeValueLabel.text = [NSString stringWithFormat:@"%@ %@", _match.homeTeam, [self fuhao:-(_pankou.handicapValue)]];
    }
    if (self.betType == 1) {
        self.titleLabel.text = @"大小分";
        self.guestValueLabel.text = [NSString stringWithFormat:@"大 %@", [self fuhao:_pankou.handicapValue]];
        self.homeValueLabel.text = [NSString stringWithFormat:@"小 %@", [self fuhao:_pankou.handicapValue]];
    }
    if (self.betType == 2) {
        self.titleLabel.text = @"胜负";
        self.guestValueLabel.text = [NSString stringWithFormat:@"%@ 胜", _match.guestTeam];
        self.homeValueLabel.text = [NSString stringWithFormat:@"%@ 胜", _match.homeTeam];
    }
    [self.oddsSegment setTitle:[NSString stringWithFormat:@"%.2f", _pankou.leftOdds] forSegmentAtIndex:0];
    [self.oddsSegment setTitle:[NSString stringWithFormat:@"%.2f", _pankou.rightOdds] forSegmentAtIndex:1];
    if (!_pankou || _match.matchStatus == -1 || (_match.matchStatus != 0 && _match.matchStatus != -1) ) {
        self.betEable = NO;
    } else {
        self.betEable = YES;
    }
}

- (void)setPankou:(Pankou *)pankou {
    if (_pankou && pankou && ![_pankou isEqualTo:pankou]) {
        self.hasUpdate = YES;
    } else {
        self.hasUpdate = NO;
    }
    if (_pankou != pankou) {
        _pankou = pankou;
    }
    [self setNeedsLayout];
}

- (void)setMatch:(Match *)match {
    if (_match != match) {
        _match = match;
    }
    [self setNeedsLayout];
}


- (void)setBetEable:(BOOL)betEable {
    _betEable = betEable;
     _oddsSegment.enabled = _amountSegment.enabled = _sureButton.enabled = betEable;
    if (_betEable) {
       _sureButton.backgroundColor = [UIColor blackColor];
    } else {
        _sureButton.backgroundColor = [UIColor colorWithHexString:@"#6C6C6C"];
    }
}

- (NSString *)fuhao:(float)num {
    if (num >= 0) {
        return [NSString stringWithFormat:@"+%.1f", num];
    }
    return [NSString stringWithFormat:@"%.1f", num];
}


- (IBAction)sureButtonAction:(UIButton *)sender {
    if (_amountSegment.selectedSegmentIndex == 0) {
        return;
    }
    if (_willBetBlock) {
        Bet *bet = [Bet new];

        bet.orderUserName = [User currentUser].username;
        bet.matchId = _match.thirdId;
        bet.betOdds = [[_oddsSegment titleForSegmentAtIndex:_oddsSegment.selectedSegmentIndex] floatValue];
        bet.betAmount = _amountSegment.selectedSegmentIndex * 10;
        bet.leftOdds = _oddsSegment.selectedSegmentIndex == 0 ? YES : NO;
        bet.betType = _betType;
        
        bet.handicapValue = _pankou.handicapValue;
        bet.leftOddsValue = _pankou.leftOdds;
        bet.rightOddsValue = _pankou.rightOdds;
        
        bet.settle = NO;
        bet.earnings = 0;
        bet.status = -1;
        bet.betDate = [NSDate date];
        bet.matchDate = _match.date;
        bet.match = _match;
        
        _willBetBlock(self, bet);
    }
}

@end
