//
//  LeftSegue.m
//  newFlows
//
//  Created by Matt Riddoch on 3/29/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "LeftSegue.h"


@implementation LeftSegue

- (void)perform{
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    //transition.subtype = kCATransitionFromRight;
    transition.subtype = kCATransitionFade;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    //[srcViewController presentViewController:destViewController animated:NO completion:nil];
    [srcViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [srcViewController.navigationController pushViewController:destViewController animated:NO];
}



@end
