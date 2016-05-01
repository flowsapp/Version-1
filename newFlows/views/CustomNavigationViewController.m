//
//  CustomNavigationViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 4/27/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "CustomNavigationViewController.h"

@interface CustomNavigationViewController ()

@end

@implementation CustomNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    return [UIStoryboardSegue segueWithIdentifier:identifier source:fromViewController destination:toViewController performHandler:^{
        UIView *fromView = fromViewController.view;
        UIView *toView = toViewController.view;
        UIView *containerView = fromView.superview;
        NSTimeInterval duration = 1.0;
        
//        [UIView transitionWithView: self.navigationController.view
//                          duration: 1.0
//                           options: UIViewAnimationOptionTransitionCrossDissolve
//                        animations: ^{
//                            [self.navigationController popToRootViewControllerAnimated:NO];
//                            //[self.navigationController setNavigationBarHidden: NO animated: NO];
//                        }
//                        completion: nil ];
        
        
//        [UIView transitionWithView:toView duration:1.0
//                           options:0
//                        animations:^{
//                            [self.navigationController popToRootViewControllerAnimated:NO];
//                        }
//                        completion:^(BOOL finished) {
//                        }];
        
        
        
        CGRect initialFrame = fromView.frame;
        CGRect offscreenRect = initialFrame;
        offscreenRect.origin.x -= CGRectGetWidth(initialFrame);
        toView.frame = offscreenRect;
        [containerView addSubview:toView];
        // Animate the view onscreen
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:0
              initialSpringVelocity:0
                            options:0
                         animations: ^{
                             //toView.frame = initialFrame;
                             [toViewController.navigationController popToViewController:toViewController animated:NO];
                         } completion: ^(BOOL finished) {
                             //[toView removeFromSuperview];
                             //[toViewController.navigationController popToViewController:toViewController animated:NO];
                         }];
        
        
    }];
    
    
}
@end
