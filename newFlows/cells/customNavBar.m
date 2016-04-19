//
//  customNavBar.m
//  newFlows
//
//  Created by Matt Riddoch on 2/29/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "customNavBar.h"
#define kAppNavBarHeight 66.0

@implementation customNavBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAppearance];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance {
    
    static BOOL appearanceInitialised = NO;
    
    if (!appearanceInitialised) {
        
        // Update the appearance of this bar to shift the icons back up to their normal position
        
        CGFloat offset = 54 - kAppNavBarHeight;
        
        [[customNavBar appearance] setTitleVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundVerticalPositionAdjustment:offset forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, offset) forBarMetrics:UIBarMetricsDefault];
        
        
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    return CGSizeMake(self.superview.frame.size.width, kAppNavBarHeight);
    
}

- (void)layoutSubviews {
    
    static CGFloat yPosForArrow = -1;
    
    [super layoutSubviews];
    
    // There's no official way to reposition the back button's arrow under iOS 7. It doesn't shift with the title.
    // We have to reposition it here instead.
    
    
    for (UIView *view in self.subviews) {
        
        // The arrow is a class of type _UINavigationBarBackIndicatorView. We're not calling any private methods, so I think
        // this is fine for the AppStore...
        //NSLog(@"%@", self.subviews);
        //[view setBackgroundColor:[UIColor greenColor]];
        
//        if ([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarBackIndicatorView"]) {
//            CGRect frame = view.frame;
//            
//            if (yPosForArrow < 0) {
//                
//                // On the first layout we work out what the actual position should be by applying our offset to the default position.
//                
//                yPosForArrow = frame.origin.y + (44 - kAppNavBarHeight);
//            }
//            
//            // Update the frame.
//            
//            frame.origin.y = yPosForArrow;
//            view.frame = frame;
//        }
    }
    
    
    
    UIView *bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5f, self.bounds.size.width, 0.5f)];
    [bottomSeperatorView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
    [self addSubview:bottomSeperatorView];
}

@end
