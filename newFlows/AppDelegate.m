//
//  AppDelegate.m
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "AppDelegate.h"
//#import "SARate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /*
    // Locate the receipt
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    
    // Test whether the receipt is present at the above path
    if(![[NSFileManager defaultManager] fileExistsAtPath:[receiptURL path]])
    {
        // Validation fails
        exit(173);
    }
    */
    // Proceed with further receipt validation steps
        
    return YES;
}

//+ (void)initialize
//{
//    //configure
//    [SARate sharedInstance].daysUntilPrompt = 5;
//    [SARate sharedInstance].usesUntilPrompt = 1;
//    [SARate sharedInstance].remindPeriod = 30;
//    [SARate sharedInstance].promptForNewVersionIfUserRated = YES;
//    //enable preview mode
//    [SARate sharedInstance].previewMode = YES;
//    
//    [SARate sharedInstance].email = @"email here";
//    // 4 and 5 stars
//    [SARate sharedInstance].minAppStoreRaiting = 4;
//    [SARate sharedInstance].emailSubject = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    [SARate sharedInstance].emailText = @"Disadvantages: ";
//    [SARate sharedInstance].headerLabelText = @"Like Flows?";
//    [SARate sharedInstance].descriptionLabelText = @"Touch the star to rate.";
//    [SARate sharedInstance].rateButtonLabelText = @"Rate";
//    [SARate sharedInstance].cancelButtonLabelText = @"Not Now";
//    [SARate sharedInstance].setRaitingAlertTitle = @"Rate";
//    [SARate sharedInstance].setRaitingAlertMessage = @"Touch the star to rate.";
//    [SARate sharedInstance].appstoreRaitingAlertTitle = @"Write a review on the AppStore";
//    [SARate sharedInstance].appstoreRaitingAlertMessage = @"Would you mind taking a moment to rate it on the AppStore? It won’t take more than a minute. Thanks for your support!";
//    [SARate sharedInstance].appstoreRaitingCancel = @"Cancel";
//    [SARate sharedInstance].appstoreRaitingButton = @"Rate It Now";
//    [SARate sharedInstance].disadvantagesAlertTitle = @"Disadvantages";
//    [SARate sharedInstance].disadvantagesAlertMessage = @"Please specify the issues in the application. We will try to fix it!";
//}
//

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
