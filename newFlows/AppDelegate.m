//
//  AppDelegate.m
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "AppDelegate.h"
//#import "SARate.h"
#import <PromiseKit/PromiseKit.h>
#import "Reachability.h"
#import "FLminMaxFlows.h"
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate ()

@end

@implementation AppDelegate{
    NSUserDefaults *defaults;
    NSMutableArray *resultArray;
    NSString *detailData;
    NSMutableArray *minMaxArray;
    NSMutableArray *testlocationArray;
}

@synthesize selectedStationArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    selectedStationArray = [[defaults objectForKey:@"selectedStationArray"] mutableCopy];
    
    resultArray = [NSMutableArray new];
    minMaxArray = [NSMutableArray new];
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    
    
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        dispatch_async(dispatch_get_main_queue(), ^{
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection"
            //                                                            message:@"You must be connected to the net to use this app"
            //                                                           delegate:nil
            //                                                  cancelButtonTitle:@"OK"
            //                                                  otherButtonTitles:nil];
            //            [alert show];
        });
    };
    
    
    
    //[defaults setObject:minMaxArray forKey:@"minMaxArray"];
    
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

#pragma mark - data pull
-(void)refreshData{
    
    
    dispatch_promise(^{
        
        return [self urlStringfromStations:selectedStationArray];
        
    }).then(^(NSString *md5){
        
        //example from USGS
 
         //http://waterservices.usgs.gov/nwis/iv/
         //?format=rdb
         //&sites=06006000,06012500,06016000,06017000,06018500
         //&period=P1D
         //&modifiedSince=PT30M
         //&parameterCd=00060
 
        
        NSDate *lastUSGSupdateDate = [defaults objectForKey:@"lastUSGSupdateDate"];
        NSDate *currentDate = [NSDate date];
        NSTimeInterval secondsSinceUpdateInterval = [lastUSGSupdateDate timeIntervalSinceNow];
        int minutesSinceUpdateInterval = secondsSinceUpdateInterval*-1/60;
        if (minutesSinceUpdateInterval<30) {
            minutesSinceUpdateInterval = 30;
        }
        
        [defaults setObject:[NSDate date] forKey:@"lastUSGSupdateDate"];
        return [NSURLConnection GET:[NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=rdb&modifiedSince=PT%iM&sites=%@&parameterCd=00060", minutesSinceUpdateInterval, md5]];
        
        //return [NSURLConnection GET:[NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=rdb&sites=%@&parameterCd=00060", md5]];
        
    }).then(^(NSString *returnData){
        
        //return [self currentDataPull:returnData];
        return [self currentDataPull:returnData isFirstPull:NO];
        
    }).then(^(NSMutableArray *responseArray){
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshNotification" object:self];
        });
    });
    
    
}


- (void)runLiveUpdate{
    
    
    
    selectedStationArray = [[defaults objectForKey:@"selectedStationArray"] mutableCopy];
    if (selectedStationArray.count > 0) {
        
#pragma mark - TODO refresh
        //[activityIndicatorView startAnimating];
        
        
        dispatch_promise(^{
            
            return [self urlStringfromStations:selectedStationArray];
            
        }).then(^(NSString *md5){
            
            [defaults setObject:[NSDate date] forKey:@"lastUSGSupdateDate"];
            return [NSURLConnection GET:[NSString stringWithFormat:@"http://waterservices.usgs.gov/nwis/iv/?format=rdb&sites=%@&parameterCd=00060", md5]];
            
        }).then(^(NSString *returnData){
            
            //return [self currentDataPull:returnData];
            return [self currentDataPull:returnData isFirstPull:YES];
            
        }).then(^(NSMutableArray *returnArray){
            
            BOOL selectedStationUpdated = [defaults boolForKey:@"selectedStationUpdated"];
            
            NSDate *savedDate = [defaults objectForKey:@"updatedDate"];
            
            NSDate *todaysDate = [NSDate date];
            NSCalendar *gregorian = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setYear:1];
            NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:todaysDate options:0];
            
            
            
            if ([savedDate compare:targetDate] == NSOrderedDescending || selectedStationUpdated) {
                
                
                //web pull
                //Add station ID pull here
                
                dispatch_promise(^{
                    
                    //pull station ID here!!
                    NSLog(@"stationtest");
                    
                }).then(^{
                    
                    return [self urlStringfromStations:selectedStationArray];
                    
                }).then(^(NSString *md5){
                    
                    
                    return [NSURLConnection GET:[NSString stringWithFormat:@"http://waterdata.usgs.gov/nwis/dvstat/?site_no=%@&format=rdb&submitted_form=parameter_selection_list&PARAmeter_cd=00060", md5]];
                    
                }).then(^(NSString *returnData){
                    
                    [self fetchedFlowData:returnData];
                    return [self urlStringfromStations:selectedStationArray];
                    
                }).then(^(NSString *md5){
                    return [NSURLConnection GET:[NSString stringWithFormat:@"http://waterdata.usgs.gov/nwis/inventory?agency_code=USGS&site_no=%@&format=rdb", md5]];
                    
                }).then(^(NSString *responseString){
                    
                    return [self detailDataPull:responseString];
                    
                    
                }).then(^(NSMutableArray *responseArray){
                    
                    [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"selectedStationUpdated"];
                    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"pullNewWeather"];
                    dispatch_async(dispatch_get_main_queue(),^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveUpdateNotification" object:self];
                    });
                    
                });
                
                
            }else{
                
                
                //local pull
                
                dispatch_promise(^{
                    
                    
                    NSString* flowData = [defaults objectForKey:@"minMaxData"];
                    return [self fetchedFlowData:flowData];
                    
                    
                }).then(^(NSString *responseString){
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshSpinNotification" object:self];
                    });
                });
                
            }
            
            
        });
    }
    
    
}



- (NSString*)urlStringfromStations:(NSMutableArray*)incomingStations{
    
    NSString *tempHolderString = [NSString new];
    for (int i = 0;i < selectedStationArray.count; i++) {
        NSMutableDictionary *tempDict = selectedStationArray[i];
        NSString *tempString = tempDict[@"stationNumber"];
        if (i < selectedStationArray.count-1) {
            NSString *commaString = [NSString stringWithFormat:@"%@,", tempString];
            tempHolderString = [NSString stringWithFormat:@"%@%@", tempHolderString, commaString];
        }else if(selectedStationArray.count == 1){
            tempHolderString = [NSString stringWithFormat:@"%@%@", tempHolderString, tempString];
        }else{
            tempHolderString = [NSString stringWithFormat:@"%@%@", tempHolderString, tempString];
        }
    }
    
    return tempHolderString;
}


#pragma mark - pull data

- (NSMutableArray*)currentDataPull:(NSString *)responseHolder isFirstPull:(BOOL)firstPull{
    
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    
    NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
    
    for (int i=0; i<workingDataArray.count; i++) {
        
        NSString *matchCriteria = @"USGS";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
        BOOL filePathMatches = [pred evaluateWithObject:[workingDataArray objectAtIndex:i]];
        
        if (filePathMatches) {
            NSArray *tempHolderArray = [[workingDataArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
            //NSLog(@"object: %@", tempHolderArray);
            NSDictionary *tempHolder = [[NSDictionary alloc] initWithObjectsAndKeys:[tempHolderArray objectAtIndex:1], @"siteNumber", [tempHolderArray objectAtIndex:4], @"siteValue", [tempHolderArray objectAtIndex:3], @"timeZone", [tempHolderArray objectAtIndex:2], @"timeStamp", nil];
            
            if (firstPull) {
                [resultArray addObject:tempHolder];
            }else{
                for (int i=0; i<resultArray.count; i++) {
                    NSDictionary *dictionaryToReplace = resultArray[i];
                    if ([tempHolder[@"siteNumber"] isEqualToString:dictionaryToReplace[@"siteNumber"]]) {
                        [resultArray replaceObjectAtIndex:i withObject:tempHolder];
                    }
                }
            }
            //
            
            
            
        }
        
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"hh:mm a";
    
#pragma mark - TODO update time string
   // _updateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    
    [defaults setObject:resultArray forKey:@"resultArray"];
    
    return resultArray;
    
}

- (NSMutableArray*)detailDataPull:(NSString *)responseHolder{
    
    [defaults setObject:responseHolder forKey:@"gpsData"];
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    NSMutableArray *returnArray = [NSMutableArray arrayWithArray:components];
    detailData = responseHolder;
    [defaults setObject:detailData forKey:@"detailData"];
    [self pullGeoLocationForTest];
    
    return returnArray;
}


#pragma mark - min max data pull

- (NSMutableArray*)fetchedFlowData:(NSString *)responseHolder{
    
    [defaults setObject:responseHolder forKey:@"minMaxData"];
    NSDate *todaysDate = [NSDate date];
    [defaults setObject:todaysDate forKey:@"updatedDate"];
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    NSMutableArray *workingDataArray = [[NSMutableArray alloc] initWithArray:components];
    NSMutableArray *cleanedHolderArray = [[NSMutableArray alloc] init];
    NSMutableArray *objectHolderArray = [[NSMutableArray alloc] init];
    for (int i=0; i<workingDataArray.count; i++) {
        NSString *matchCriteria = @"USGS";
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", matchCriteria];
        BOOL filePathMatches = [pred evaluateWithObject:[workingDataArray objectAtIndex:i]];
        if (filePathMatches) {
            
            NSArray *tempHolderArray = [[workingDataArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
            
            FLminMaxFlows *flowHolder = [[FLminMaxFlows alloc] init];
            
            flowHolder.agencyCd = [tempHolderArray objectAtIndex:0];
            flowHolder.siteNum = [tempHolderArray objectAtIndex:1];
            flowHolder.paramaterCd = [tempHolderArray objectAtIndex:2];
            flowHolder.monthNu = [tempHolderArray objectAtIndex:4];
            flowHolder.dayNu = [tempHolderArray objectAtIndex:5];
            flowHolder.meanVa = [tempHolderArray objectAtIndex:13];
            flowHolder.p25Va = [tempHolderArray objectAtIndex:17];
            flowHolder.p75Va = [tempHolderArray objectAtIndex:19];
            
            [objectHolderArray addObject:flowHolder];
            
            flowHolder = nil;
            
            [cleanedHolderArray addObject:tempHolderArray];
            
        }
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate]; // Get necessary date components
    
    NSInteger month = [dateComp month]; //gives you month
    NSInteger day = [dateComp day]; //gives you day
    
    [minMaxArray removeAllObjects];
    
    for (FLminMaxFlows *temp in objectHolderArray) {
        
        if ([temp.monthNu isEqualToString:[NSString stringWithFormat:@"%li", (long)month]]) {
            if ([temp.dayNu isEqualToString:[NSString stringWithFormat:@"%li", (long)day]]) {
                
                NSDictionary *holderDict = [[NSDictionary alloc] initWithObjectsAndKeys:temp.meanVa, @"meanValue", temp.p25Va, @"25Value", temp.p75Va, @"75Value", temp.siteNum, @"siteNumber", nil];
                [minMaxArray addObject:holderDict];
                
            }
        }
        
        
    }
    
    
    [defaults setObject:minMaxArray forKey:@"minMaxArray"];
    
    return minMaxArray;
    
}

-(void)pullGeoLocationForTest{
    
    NSArray *components = [detailData componentsSeparatedByString:@"\n"];
    
    NSMutableArray *workingArray = [[NSMutableArray alloc] initWithArray:components];
    
    NSMutableArray *stationArray = [NSMutableArray new];
    
    for (int i=0; i<workingArray.count; i++) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@", @"USGS"];
        BOOL filePathMatches = [pred evaluateWithObject:[workingArray objectAtIndex:i]];
        if (filePathMatches) {
            NSArray *tempHolderArray = [[workingArray objectAtIndex:i] componentsSeparatedByString:@"\t"];
            [stationArray addObject:tempHolderArray];
            
            
        }
        
    }
    
    testlocationArray = [NSMutableArray new];
    
    for (int i=0; i<stationArray.count; i++) {
        NSArray *tempHolderArray = stationArray[i];
        
        NSString *tempStationNumber = tempHolderArray[1];
        NSString *latString = tempHolderArray[6];
        NSString *longString = tempHolderArray[7];
        
        NSString *endOneLatString;
        NSString *endTwoLatString;
        
        NSString *endOneLongString;
        NSString *endTwoLongString;
        
        NSCharacterSet *latcset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        NSRange latrange = [latString rangeOfCharacterFromSet:latcset];
        if (latrange.location == NSNotFound) {
            // no ( or ) in the string
        } else {
            NSRange latRange = [latString rangeOfString:@"."];
            latString = [latString substringToIndex:latRange.location];
        }
        
        NSCharacterSet *longcset = [NSCharacterSet characterSetWithCharactersInString:@"."];
        NSRange longrange = [longString rangeOfCharacterFromSet:longcset];
        if (longrange.location == NSNotFound) {
            // no ( or ) in the string
        } else {
            NSRange longRange = [longString rangeOfString:@"."];
            longString = [longString substringToIndex:longRange.location];
        }
        
        endOneLatString = [latString substringToIndex:[latString length] - 4];
        endOneLongString = [longString substringToIndex:[longString length] - 4];
        endTwoLatString = [latString substringFromIndex:[latString length] - 4];
        endTwoLongString = [longString substringFromIndex:[longString length] - 4];
        
        NSString *longSec = [endTwoLongString substringFromIndex:[endTwoLongString length] - 2];
        NSString *longMin = [endTwoLongString substringToIndex:[endTwoLongString length] - 2];
        double longMinutes = [longMin doubleValue] / 60;
        double longSeconds = [longSec doubleValue] / 3600;
        double longTotal = [endOneLongString doubleValue] + longMinutes + longSeconds;
        longTotal = -longTotal;
        NSString *latSec = [endTwoLatString substringFromIndex:[endTwoLatString length] - 2];
        NSString *latMin = [endTwoLatString substringToIndex:[endTwoLatString length] - 2];
        double latMinutes = [latMin doubleValue] / 60;
        double LatSeconds = [latSec doubleValue] / 3600;
        double latTotal = [endOneLatString doubleValue] + latMinutes + LatSeconds;
        
        
        
        
        
        
        NSDictionary *tempLocationDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:longTotal], @"longTotal", [NSNumber numberWithDouble:latTotal], @"latTotal", tempStationNumber, @"stationNumber", nil];
        
        [testlocationArray addObject:tempLocationDictionary];
        
        NSLog(@"%@", tempLocationDictionary);
        //for (NSMutableDictionary *stationDict in selectedStationArray) {
        for (int i=0; i<selectedStationArray.count; i++) {
            NSMutableDictionary *stationDict = [selectedStationArray[i] mutableCopy];
            if ([stationDict[@"stationNumber"] isEqualToString:tempStationNumber]) {
                [stationDict setObject:[NSNumber numberWithDouble:longTotal] forKey:@"longTotal"];
                [stationDict setObject:[NSNumber numberWithDouble:latTotal] forKey:@"latTotal"];
#pragma mark - TODO test for nil weatherInfo station data
                NSDictionary *weatherInfo = [self closestLocationToLocation:[[CLLocation alloc] initWithLatitude:[[NSNumber numberWithDouble:latTotal] doubleValue] longitude:[[NSNumber numberWithDouble:longTotal] doubleValue]]];
                [stationDict setObject:weatherInfo[@"_id"] forKey:@"weatherStationId"];
                [selectedStationArray replaceObjectAtIndex:i withObject:stationDict];
                [defaults setObject:selectedStationArray forKey:@"selectedStationArray"];
            }
            
        }
        
    }
    
}

- (NSDictionary*)closestLocationToLocation:(CLLocation*)currLocation
{
    CLLocationDistance minDistance = 99999999999;
    
    CLLocation *closestLocation = nil;
    
    NSDictionary *chosenDict;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //NSError* error = nil; // Declare a variable to hold the error upon return
    //id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error]; // Try to convert your data
    //NSLog(@"obj: %@ ; error: %@", obj, error);
    
    
    //for (CLLocation *location in arrayOfLocations) {
    for (NSDictionary *locationDict in json) {
        
        NSDictionary *innerDict = locationDict[@"coord"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[innerDict[@"lat"] doubleValue] longitude:[innerDict[@"lon"] doubleValue]];;
        
        CLLocationDistance distance = [location distanceFromLocation:currLocation];
        
        if (distance <= minDistance
            || closestLocation == nil) {
            minDistance = distance;
            closestLocation = location;
            chosenDict = locationDict;
        }
    }
    
    //closestLocation is now the location from your array which is closest to the current location or nil if there are no locations in your array.
    
    //return closestLocation;
    return chosenDict;
    
}


@end
