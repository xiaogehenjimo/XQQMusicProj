//
//  XQQLrcCell.h
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XQQLrcLabel.h"
@interface XQQLrcCell : UITableViewCell
/**自定制label*/
@property(nonatomic, strong)   XQQLrcLabel * lrcLabel;
+ (instancetype)lrcCellWithTableView:(UITableView*)tableView;
@end
