//
//  DisclaimerViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 3/23/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "UIColor+Hexadecimal.h"

@interface DisclaimerViewController ()

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
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    label.textColor = [UIColor whiteColor];
    label.text = @"Disclaimer";
    
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = label;
    
    NSDictionary *barButtonAppearanceDict = @{NSForegroundColorAttributeName: [UIColor colorWithHex:@"ACACAC"]};
    //[[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithHex:@"ACACAC"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)exitClicked:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
