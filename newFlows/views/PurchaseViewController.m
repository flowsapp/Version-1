//
//  PurchaseViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 5/2/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "PurchaseViewController.h"
#import "UIColor+Hexadecimal.h"
#import "MKStoreKit.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    self.navigationItem.titleView = img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purchaseClicked:(id)sender {
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"com.flowsapp.extendedStaions"];
}


- (IBAction)cancelClicked:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    //transition.subtype = kCATransitionFromRight;
    transition.subtype = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
