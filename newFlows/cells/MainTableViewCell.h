//
//  MainTableViewCell.h
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end
