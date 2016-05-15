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
#import "UIScrollView+EmptyDataSet.h"
#import "MKStoreKit.h"

@interface PurchaseViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation PurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[MKStoreKit sharedKit] startProductRequest];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      
                                                      [self performSelectorOnMainThread:@selector(purchaseUpgradewithNote:) withObject:note waitUntilDone:YES];
                                                      
                                                      
                                                  }];
    
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

    
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    self.navigationItem.titleView = img;
    
    // A little trick for removing the cell separators
    _mainTable.tableFooterView = [UIView new];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)purchaseUpgradewithNote:(NSNotification*)incomingNote{
    NSLog(@"Purchased/Subscribed to product with id: %@", [incomingNote object]);
    [[NSUserDefaults standardUserDefaults] setBool:[NSNumber numberWithBool:YES] forKey:@"upgradePurchased"];
    [[NSUserDefaults standardUserDefaults] setBool:[NSNumber numberWithBool:YES] forKey:@"segueToRivers"];
    
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

#pragma mark - EmptyDataset

//- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
//{
//    return [UIImage imageNamed:@"HeaderLogo"];
//}
//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"$.99 gets you access to 10 stations";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 20.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.firstLineHeadIndent = 20.0;
    paragraphStyle.tailIndent = -20.0;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"FFFFFF"],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
//{
//    NSString *text = @"Lets go ahead and choose a couple of sites to monitor!! Once you have chosen sites you can monitor stream flows in real time";
//
//    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
//    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
//    paragraph.alignment = NSTextAlignmentCenter;
//
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
//                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
//                                 NSParagraphStyleAttributeName: paragraph};
//
//    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
//}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    /*
     NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
     NSForegroundColorAttributeName: [UIColor whiteColor]};
     
     return [[NSAttributedString alloc] initWithString:@"Add a Station" attributes:attributes];
     */
    
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"Upgrade";
    font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
    textColor = [UIColor colorWithHex:(state == UIControlStateNormal) ? @"ffffff" : @"acacac"];
    //textColor = [UIColor colorWithHex:@"ffffff"];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:@"Upgrade" attributes:attributes];
    
}


//- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    //return [UIImage imageNamed:@"addStation.png"];
    NSString *imageName = @"addStation.png";
    //if (state == UIControlStateHighlighted) imageName = [imageName stringByAppendingString:@"button_highlight.png"];
    //if (state == UIControlStateNormal) imageName = @"button_normal.png";
    
    //UIEdgeInsets capInsets = UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0);
    //UIEdgeInsets rectInsets = UIEdgeInsetsMake(0.0, 10, 0.0, 10);
    //UIEdgeInsets capInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    //UIEdgeInsets rectInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    
    //return [UIImage imageNamed:imageName];
    //return [[[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:rectInsets];
    return [[[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, -self.view.bounds.size.width/4, 0, -self.view.bounds.size.width/4)];
}

//- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
//{
//
//    return [UIColor colorWithHex:@"aaaaaa"];
//
//}



- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    
    return self.view.bounds.size.height/8;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -65.0;
}

#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}


#pragma mark - UITableviewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (chosenObjectArray.count == 0) {
    //    return 1;
    //}else{
    return 0;
    //}
    
}

#pragma mark -

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:@"com.flowsapp.flowspro"];
}




@end
