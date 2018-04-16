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
@end

@implementation BetCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5;
    self.updateStausView.layer.masksToBounds = YES;
    self.updateStausView.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
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
        bet.betType = _betType;
        bet.betAmount = _amountSegment.selectedSegmentIndex * 10;
        if (self.account.balance < bet.betAmount) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"余额不足";
            [hud hideAnimated:YES afterDelay:.5];
            return;
        }
        
        bet.orderUserName = [User currentUser].username;
        bet.betType = 0;
        bet.betOdds = [[_oddsSegment titleForSegmentAtIndex:_oddsSegment.selectedSegmentIndex] floatValue];
        bet.leftOdds = _oddsSegment.selectedSegmentIndex == 0 ? YES : NO;
        bet.matchId = _match.thirdId;
        bet.matchDate = _match.date;
        bet.handicapValue = _match.matchOdds.asiaLet.bet365.handicapValue;
        
        bet.settle = NO;
        bet.earnings = 0;
        bet.status = -1;
        bet.match = _match;
        bet.betDate = [NSDate date];
        
        _willBetBlock(self, bet);
    }
}

@end
