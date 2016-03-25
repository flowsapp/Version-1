//
//  customNavBar.m
//  newFlows
//
//  Created by Matt Riddoch on 2/29/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "customNavBar.h"

const CGFloat VFSNavigationBarHeightIncrease = 5.0f;


@implementation customNavBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    
    
    //[self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+20)];
    //[self setTitleVerticalPositionAdjustment:-(VFSNavigationBarHeightIncrease)/2 forBarMetrics:UIBarMetricsDefault];
    
    //[self setTransform:CGAffineTransformMakeTranslation(0, -20)];
}


- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize amendedSize = [super sizeThatFits:size];
    amendedSize.height += VFSNavigationBarHeightIncrease;
    
    return amendedSize;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    
//    NSArray *classNamesToReposition = @[@"UINavigationItemView", @"_UINavigationBarBackground", @"UINavigationButton"];
//    
//    for (UIView *view in [self subviews]) {
//        
//        if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
//            
//            //CGRect bounds = [self bounds];
//            CGRect frame = [view frame];
//            //frame.origin.y = bounds.origin.y + VFSNavigationBarHeightIncrease;
//            //frame.size.height = bounds.size.height - 20.f;
//            frame.origin.y -= VFSNavigationBarHeightIncrease/2;
//            
//            [view setFrame:frame];
//        }
//    }
//    
//    UIView *bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5f, self.bounds.size.width, 0.5f)];
//    [bottomSeperatorView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
//    [self addSubview:bottomSeperatorView];
//
//    
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //NSArray *classNamesToReposition = @[@"_UINavigationBarBackground", @"UINavigationItemView", @"UINavigationButton", @"UIBarButtonItem"];
//    NSArray *classNamesToReposition = @[@"_UINavigationBarBackground", @"UINavigationItemView", @"UINavigationButton", @"UI"];
//    
//    for (UIView *view in [self subviews]) {
//    
//        if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
//            
//            
//            CGRect frame = [view frame];
//            
//            frame.origin.y -= VFSNavigationBarHeightIncrease/2;
//            
//            
//            
//            [view setFrame:frame];
//        }
//    }
    
    
    UIView *bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5f, self.bounds.size.width, 0.5f)];
    [bottomSeperatorView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
    [self addSubview:bottomSeperatorView];

}

//- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated {
//    return [super popNavigationItemAnimated:NO];
//}




@end
