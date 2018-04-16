//
//  BetCell.m
//  RedJ
//
//  Created by gakki's vi~ on 2018/4/16.
//  Copyright © 2018年 zhangyangwei.com. All rights reserved.
//

#import "BetCell.h"

@interface BetCell ()
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
}

@end
