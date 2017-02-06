//
//  XQQLrcCell.m
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQLrcCell.h"

@implementation XQQLrcCell

+ (instancetype)lrcCellWithTableView:(UITableView *)tableView{
    static NSString * cellID = @"myCell";
    XQQLrcCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[XQQLrcCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化自定制的label
        XQQLrcLabel * lrcLabel = [[XQQLrcLabel alloc]init];
        [self.contentView addSubview:lrcLabel];
        self.lrcLabel = lrcLabel;
        //添加约束
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
        }];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        lrcLabel.font = [UIFont systemFontOfSize:14];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.textColor = [UIColor whiteColor];
    }
    return self;
}
@end
