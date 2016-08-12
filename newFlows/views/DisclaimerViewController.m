//
//  DisclaimerViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 3/23/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "UIColor+Hexadecimal.h"
#import "pushAnimator.h"
#import "popAnimator.h"
#import "MKStoreKit.h"

@interface DisclaimerViewController () <UINavigationControllerDelegate>

@end

@implementation DisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0f];
    label.textColor = [UIColor whiteColor];
    label.text = @"Disclaimer";
    
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = label;
    self.navigationController.delegate = self;
    
    
    
    
    //NSDictionary *barButtonAppearanceDict = @{NSForegroundColorAttributeName: [UIColor greenColor]};
    //[[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    //[UINavigationBar appearance].tintColor = [UIColor greenColor];
    //self.navigationController.navigationBar.tintColor = [UIColor greenColor];
    
    //[[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHex:@"ACACAC"]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor greenColor]];
    
    
    [[MKStoreKit sharedKit] startProductRequest];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"upgradePurchased"];
                                                  }];
    */
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"upgradePurchased"];
                                                      NSLog(@"Restored Purchases");
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                  }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (IBAction)restoreClicked:(id)sender {
    [[MKStoreKit sharedKit]restorePurchases];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush)
        return [[pushAnimator alloc] init];
    
    if (operation == UINavigationControllerOperationPop)
        return [[popAnimator alloc] init];
    
    return nil;
}

- (IBAction)exitClicked:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    //transition.subtype = kCATransitionFromRight;
    transition.subtype = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    [self.navigationController popViewControllerAnimated:NO];
}

@end
