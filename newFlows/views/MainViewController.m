//
//  MainViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "MainViewController.h"
#import "MainTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Reachability.h"

#import "FLminMaxFlows.h"
#import "SwipeViewController.h"
//#import "UIView+Facade.h"
#import <QuartzCore/QuartzCore.h>
//#import "ODRefreshControl.h"
#import <JTMaterialSpinner/JTMaterialSpinner.h>

#import <PromiseKit/PromiseKit.h>

#import <CoreLocation/CoreLocation.h>
#import "KFOpenWeatherMapAPIClient.h"
#import "KFOWMDailyForecastResponseModel.h"
#import "KFOWMDailyForecastListModel.h"
#import "KFOWMWeatherModel.h"
#import "KFOWMForecastTemperatureModel.h"
//#import "customNavBar.h"
#import "KFOWMCityModel.h"
#import "UIColor+Hexadecimal.h"

#import "pushAnimator.h"
#import "popAnimator.h"

#import "NSDate+HumanizedTime.h"


#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet JTMaterialSpinner *spinnerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic) NSString *updateString;

@end

@implementation MainViewController{
    
    NSMutableArray *selectedStationArray;
    NSUserDefaults *defaults;
    NSNumber *stationNumber;
    NSString *stationTitle;
    NSMutableArray *resultArray;
    NSMutableArray *minMaxArray;
    //NSData *detailData;
    NSString *detailData;
    //NSInteger selectedIndex;
    UITableViewHeaderFooterView *header;
    UILabel *headerLabel;
    BOOL hasTappedRow;
    
    NSMutableArray *testlocationArray;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Customize the line width
    _spinnerView.circleLayer.lineWidth = 2.0;
    
    // Change the color of the line
    _spinnerView.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    
    self.navigationController.delegate = self;
#pragma mark - TODO refresh control
    
    [self.mainTable setSeparatorColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [_mainTable addSubview:_refreshControl]; //assumes tableView is @property
    
    resultArray = [NSMutableArray new];
    minMaxArray = [NSMutableArray new];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"infoicon"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(leftButtonPressed:)];
    [leftItem setTintColor:[UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0]];
    
    //self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    self.navigationItem.titleView = img;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    _mainTable.allowsMultipleSelectionDuringEditing = NO;
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                            message:@"You must be connected to the net to use this app"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    };
    
    //TODO redundent pulls
    
    
    selectedStationArray = [[defaults objectForKey:@"selectedStationArray"] mutableCopy];
    
    if (selectedStationArray.count>0) {
        [_spinnerView beginRefreshing];
        [self runLiveUpdate];
    }
    

    
    // A little trick for removing the cell separators
    _mainTable.tableFooterView = [UIView new];
    
    self.navigationController.navigationBarHidden = YES;
    
    [UIView transitionWithView: self.navigationController.view
                      duration: 0.3
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^{
                        
                        [self.navigationController setNavigationBarHidden: NO animated: NO];
                    }
                    completion: nil ];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    selectedStationArray = [[defaults objectForKey:@"selectedStationArray"] mutableCopy];
    BOOL segueBool = [defaults boolForKey:@"segueToRivers"];
    if ([defaults boolForKey:@"segueToRivers"]) {
        
        //[defaults setBool:[NSNumber numberWithBool:NO] forKey:@"segueToRivers"];
        [self performSegueWithIdentifier:@"addStationSegue" sender:self];
    }else if ([defaults boolForKey:@"selectedStationUpdated"]) {
        if (selectedStationArray.count==1) {
            [_mainTable reloadEmptyDataSet];
        }
        [_spinnerView forceBeginRefreshing];
        [self runLiveUpdate];
    }
    
//    if ([[NSDate date] compare:[defaults objectForKey:@""]]) {
//        //pull data
//    }
    
    if (selectedStationArray.count == 10) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBar.alpha = 0.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                    [_mainTable reloadData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedStationArray.count-1 inSection:0];
                    [_mainTable scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
#pragma mark - TODO refresh
                    //[activityIndicatorView stopAnimating];
                    [_spinnerView endRefreshing];
                    
                });
                
                
            }else{
                
                
                //local pull
                
                dispatch_promise(^{
                    
                    
                    NSString* flowData = [defaults objectForKey:@"minMaxData"];
                    return [self fetchedFlowData:flowData];
                    
                    
                }).then(^(NSString *responseString){
                    
                    [_mainTable reloadData];
#pragma mark - TODO refresh
                    //[activityIndicatorView stopAnimating];
                    [_spinnerView endRefreshing];
                    
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


- (IBAction)addClicked:(id)sender {
    
    
    // for the moment total stations are capped at 10?
    // test for station array count and hasPurchased bool
    NSLog(@"%@", [NSNumber numberWithBool:[defaults boolForKey:@"upgradePurchased"]]);
    
    if (selectedStationArray.count <=2) {
        [self performSegueWithIdentifier:@"addStationSegue" sender:self];
    }else if(selectedStationArray.count <=9 && [defaults boolForKey:@"upgradePurchased"]){
        [self performSegueWithIdentifier:@"addStationSegue" sender:self];
    }else if (selectedStationArray.count ==3 && ![defaults boolForKey:@"upgradePurchased"]){
        [self performSegueWithIdentifier:@"purchaseSegue" sender:self];
    }else{
        //ten station max
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are at your maximum stations"
                                                        message:@"Delete a stations text here?"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}

- (void)leftButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"aboutSegue" sender:self];
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

    
    _updateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    
    
    
    return resultArray;
    
}

- (NSMutableArray*)detailDataPull:(NSString *)responseHolder{
    
    [defaults setObject:responseHolder forKey:@"gpsData"];
    NSArray *components = [responseHolder componentsSeparatedByString:@"\n"];
    NSMutableArray *returnArray = [NSMutableArray arrayWithArray:components];
    detailData = responseHolder;
    
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
    
    return minMaxArray;
    
}


#pragma mark - EmptyDataset


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Keep a pulse on the rivers you care about";
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


- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    
    NSString *text = nil;
    UIFont *font = nil;
    UIColor *textColor = nil;
    
    text = @"Add a Station";
    font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f];
    textColor = [UIColor colorWithHex:(state == UIControlStateNormal) ? @"ffffff" : @"acacac"];
    //textColor = [UIColor colorWithHex:@"ffffff"];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:@"Add a Station" attributes:attributes];
    
}


//- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    NSString *imageName = @"addStation.png";
        return [[[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, -self.view.bounds.size.width/4, 0, -self.view.bounds.size.width/4)];
}



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
    if (selectedStationArray.count>0) {
        return NO;
    }else{
        return YES;
    }
    
}


#pragma mark - UITableviewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 27.0f;
    
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    header = (UITableViewHeaderFooterView *)view;
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]] && selectedStationArray.count != 0) {
        ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
        
        
        UIView *bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height-0.5f, view.bounds.size.width, 0.5f)];
        [bottomSeperatorView setBackgroundColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
        
        //[view addSubview:topHeaderSeperator];
        [view addSubview:bottomSeperatorView];
        
        if (header.textLabel.text.length > 0) {
            header.textLabel.text = [NSString stringWithFormat:@"%@%@", [[header.textLabel.text substringToIndex:12] capitalizedString], [[header.textLabel.text substringFromIndex:12] uppercaseString]];
        }
        header.textLabel.textColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0];
        header.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11.0f];
        header.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (selectedStationArray.count > 0) {
        if (_updateString.length == 0) {
            return @"Last updated at: N/A";
        }else{
            return [NSString stringWithFormat:@"Last updated: %@", _updateString];
        }
    }else{
        return @"";
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (chosenObjectArray.count == 0) {
    //    return 1;
    //}else{
    return selectedStationArray.count;
    //}
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        if (selectedStationArray.count == 10) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
        
        [selectedStationArray removeObjectAtIndex:indexPath.row];
        
        [defaults setObject:selectedStationArray forKey:@"selectedStationArray"];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"pullNewWeather"];
        
        if (selectedStationArray.count == 0) {
            [_mainTable beginUpdates];
            //Update your data model here
            [_mainTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [_mainTable reloadEmptyDataSet];
            [_mainTable endUpdates];
        }
        
        
    }
}




#pragma mark -

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    [self performSegueWithIdentifier:@"addStationSegue" sender:self];
    [_spinnerView beginRefreshing];
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"mainCell";
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //cell.separatorInset = UIEdgeInsetsZero;
    //NSDictionary *cellDict = selectedStationArray[indexPath.row];
    NSMutableDictionary *cellDict = selectedStationArray[indexPath.row];
    NSMutableDictionary *titleDict = [NSMutableDictionary new];
    if (cellDict[@"cleanedTitle"]){
        titleDict = cellDict[@"cleanedTitle"];
    }else{
        [titleDict setObject:cellDict[@"stationTitle"] forKey:@"nameHolder"];
    }
    if (resultArray.count > 0 && minMaxArray.count > 0) {
        //NSDictionary *resultDict = resultArray[indexPath.row];
        for (NSDictionary *resultDict in resultArray) {
            if ([resultDict[@"siteNumber"] isEqualToString:cellDict[@"stationNumber"]]) {
                cell.resultLabel.text = resultDict[@"siteValue"];
                
                for (NSDictionary *meanDict in minMaxArray) {
                    if ([meanDict[@"siteNumber"] isEqualToString:cellDict[@"stationNumber"]]) {
                        if ([resultDict[@"siteValue"] isEqualToString:@"Ssn"] || [resultDict[@"siteValue"] isEqualToString:@"Dis"] || [resultDict[@"siteValue"] isEqualToString:@"Ice"]) {
                            cell.resultLabel.text = @"Ice";
                            [cell.resultLabel setTextColor:[UIColor whiteColor]];
                        }else{
                            if ([resultDict[@"siteValue"] doubleValue] < [meanDict[@"25Value"] doubleValue]) {
                                //red
                                [cell.resultLabel setTextColor:[UIColor colorWithRed:0.93 green:0.39 blue:0.25 alpha:1.0]];
                            }else if ([resultDict[@"siteValue"] doubleValue] > [meanDict[@"75Value"] doubleValue]) {
                                //blue
                                [cell.resultLabel setTextColor:[UIColor colorWithRed:0.15 green:0.58 blue:1.00 alpha:1.0]];
                            }else{
                                //green
                                [cell.resultLabel setTextColor:[UIColor colorWithRed:0.42 green:0.91 blue:0.46 alpha:1.0]];
                                
                            }
                        }
                        
                        
                    }
                }
                
            }
        }
        
    }
    //strip new line /n chars
    
    NSString *titleString = [titleDict[@"nameHolder"] stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    NSString *subTitleString = [titleDict[@"locationHolder"] stringByReplacingOccurrencesOfString: @"\r" withString:@""];
    
    cell.titleLabel.text = titleString;
    cell.subTitleLabel.text = subTitleString;
    cell.subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.subTitleLabel.numberOfLines = 0;
    [cell.subTitleLabel setTextColor:[UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_spinnerView beginRefreshing];
    if (!hasTappedRow) {
        hasTappedRow = YES;
        
        [defaults setObject:detailData forKey:@"detailData"];
        [defaults setObject:resultArray forKey:@"resultArray"];
        [defaults setObject:minMaxArray forKey:@"minMaxArray"];
        [defaults setInteger:indexPath.row forKey:@"selectedIndex"];
        
        
        BOOL pullNewWeather = [defaults boolForKey:@"pullNewWeather"];
        
        NSDate *lastWeatherPullDate = [defaults objectForKey:@"updatedWeatherDate"];
        
        NSDate *todaysDate = [NSDate date];
        
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:3];
        NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:todaysDate options:0];
        if (lastWeatherPullDate) {
            if ([lastWeatherPullDate compare:targetDate] == NSOrderedDescending || pullNewWeather) {
                [self testWeatherWithArray:selectedStationArray];
            }else{
                [_spinnerView endRefreshing];
                hasTappedRow = NO;
                [self performSegueWithIdentifier:@"swipeSegue" sender:self];
            }
        }else{
            [self testWeatherWithArray:selectedStationArray];
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


- (void)testWeatherWithArray:(NSMutableArray*)incomingLocations{
    
    NSMutableArray *weatherDataArray = [NSMutableArray new];
    
    KFOpenWeatherMapAPIClient *apiClient = [[KFOpenWeatherMapAPIClient alloc] initWithAPIKey:@"c25c6e80d777846d79d2b0f464f5b7f3" andAPIVersion:@"2.5"];
    //[apiClient dailyForecastForCoordinate:stationLocation numberOfDays:3 withResultBlock:^(BOOL success, id responseData, NSError *error)
    
    
    
    NSMutableArray *locations = [NSMutableArray new];
    
    for (NSDictionary *innerDict in incomingLocations) {
        [locations addObject:innerDict[@"weatherStationId"]];
    }
    
    
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < locations.count; i++) {
        // Enter the group for each request we create
        dispatch_group_enter(group);
        
        NSLog(@"pause here");
        [NSThread sleepForTimeInterval:0.1];
        
        [apiClient dailyForecastForCityId:locations[i] numberOfDays:3 withResultBlock:^(BOOL success, id responseData, NSError *error)
         
         {
             
             NSLog(@"top of loop");
             
             if (success)
             {
                 
                 KFOWMDailyForecastResponseModel *responseModel = (KFOWMDailyForecastResponseModel *)responseData;
                 
                 NSMutableArray *intermediateArray = [NSMutableArray new];
                 NSLog(@"response:%@", responseData);
                 
                 for (int i = 0; i < responseModel.list.count; i++) {
                     
                     KFOWMDailyForecastListModel *listModel = responseModel.list[i];
                     
                     
                     
                     //KFOWMForecastTemperatureModel *tempArray = listModel.temperature;
                     
                     NSNumber *lowNum = [self kelvinToFahrenheit:listModel.temperature.min];
                     NSNumber *highNum = [self kelvinToFahrenheit:listModel.temperature.max];
                     
                     
                     NSDate *testDate = listModel.dt; //innerDict[@"dt"];
                     NSDateFormatter *df = [[NSDateFormatter alloc] init];
                     df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                     [df setDateFormat:@"EEEE"];
                     
                     NSString *dateString = [df stringFromDate:testDate];
                     NSArray *weatherHolder = listModel.weather;
                     KFOWMWeatherModel *weatherModel = weatherHolder[0];
                     NSString *iconString = weatherModel.icon;
                    
                     
                     NSDictionary *weatherDict = [[NSDictionary alloc] initWithObjectsAndKeys:lowNum, @"lowNum", highNum, @"highNum", dateString, @"dateString", iconString, @"iconString", responseModel.city.cityId, @"cityId", nil];
                     
                     [intermediateArray addObject:weatherDict];
                     
                 }
                 
                 [weatherDataArray addObject:intermediateArray];
                 dispatch_group_leave(group);
                 
             }else{
                 NSLog(@"could not get weather: %@", error);
                 NSMutableArray *intermediateArray = [NSMutableArray new];
                 NSMutableDictionary *errorDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"error occured", @"error", nil];
                 [intermediateArray addObject:errorDict];
                 [weatherDataArray addObject:intermediateArray];
                 dispatch_group_leave(group);
             }
             
         }];

        
        
        
        
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [defaults setObject:weatherDataArray forKey:@"weatherArray"];
#pragma mark - TODO refresh
        //[activityIndicatorView stopAnimating];
        [_spinnerView endRefreshing];
        hasTappedRow = NO;
        [defaults setObject:[NSDate date] forKey:@"updatedWeatherDate"];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"pullNewWeather"];
        
        [self performSegueWithIdentifier:@"swipeSegue" sender:self];
        NSLog(@"finished?");
    });

    
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




- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue
{
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    
    if ([segue.identifier isEqualToString:@"addStationSegue"]) {
        
}
    

    
    
}



- (NSNumber *)kelvinToFahrenheit:(NSNumber *)kelvin
{
    return @((kelvin.floatValue * 9.0f/5.0f) - 459.67f);
}


@end
