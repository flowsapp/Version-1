//
//  SwipeViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 12/9/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "SwipeViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
//#import "OWMWeatherAPI.h"
//#import "KFOpenWeatherMapAPIClient.h"
//#import "KFOWMDailyForecastResponseModel.h"
//#import "KFOWMDailyForecastListModel.h"
//#import "KFOWMWeatherModel.h"
//#import "KFOWMForecastTemperatureModel.h"
#import "UIView+Facade.h"
#import <QuartzCore/QuartzCore.h>

#import <PromiseKit/PromiseKit.h>


#import "CustomSwipeview.h"

#define METERS_PER_MILE 1609.344


@interface SwipeViewController () <SwipeViewDataSource, SwipeViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

//@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SwipeViewController{
    UIPageControl *pageControl;
    UIButton *backButton;
    UIButton *mapButton;
    //MKMapView *mapView;
    BOOL mapEnabled;
    NSMutableArray *weatherCacheArray;
    //NSArray *weatherHolder;
    NSUserDefaults *defaults;
    BOOL firstViewLoad;
    
    NSString *incomingData;
    NSMutableArray *incomingItems;
    //int incomingIndex;
    NSMutableArray *locationArray;
    NSMutableArray *resultArray;
    NSMutableArray *minMaxArray;
    BOOL isLoading;
    BOOL isLoadingSecond;
}

//@synthesize incomingItems;
//@synthesize incomingData;
//@synthesize incomingResult;
//@synthesize incomingMinMax;
//@synthesize incomingIndex;
@synthesize testArray;

- (void)awakeFromNib
{
    //set up data
    //your swipeView should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen

    
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    incomingData = [defaults objectForKey:@"detailData"];
    incomingItems = [defaults objectForKey:@"selectedStationArray"];
    resultArray = [defaults objectForKey:@"resultArray"];
    minMaxArray = [defaults objectForKey:@"minMaxArray"];
    weatherCacheArray = [defaults objectForKey:@"weatherArray"];
    
    
    NSLog(@"test");

    

}





#pragma mark - everything else
- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    //this is true even if your project is using ARC, unless
    //you are targeting iOS 5 as a minimum deployment target
    
    _swipeView.delegate = nil;
    _swipeView.dataSource = nil;
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"dataHere %@", testArray);
    
    firstViewLoad = YES;
//    mapView = [[MKMapView alloc] init];
//
//    mapView.delegate = self;
    
    
    
    //configure swipeView
    _swipeView.pagingEnabled = YES;
    
    
    backButton = [[UIButton alloc] init];
    [backButton setTag:1001];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backButton];
    [backButton anchorTopLeftWithLeftPadding:0 topPadding:27 width:50 height:50];
    UIImage *backArrow = [UIImage imageNamed:@"BackIcon"];
    [backButton setImage:backArrow forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClickedPage:) forControlEvents:UIControlEventTouchUpInside];
    
    mapButton = [[UIButton alloc] init];
    [mapButton setTag:1002];
    [mapButton setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mapButton];
    UIImage *mapNavIcon = [UIImage imageNamed:@"GreyMapIcon"];
    [mapButton setImage:mapNavIcon forState:UIControlStateNormal];
    [mapButton anchorTopRightWithRightPadding:0 topPadding:27 width:50 height:50];
    //[mapButton anchorTopCenterWithTopPadding:20 width:30 height:30];
    [mapButton addTarget:self action:@selector(mapClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    pageControl = [[UIPageControl alloc] init];
    [self.view addSubview:pageControl];
    [pageControl setNumberOfPages:incomingItems.count];
    //[pageControl setBackgroundColor:[UIColor redColor]];
    //[pageControl anchorBottomCenterWithBottomPadding:-(self.swipeView.bounds.size.width/3) width:150 height:20];
    //[pageControl anchorBottomCenterWithBottomPadding:-50 width:150 height:20];
    [pageControl anchorBottomCenterFillingWidthWithLeftAndRightPadding:50 bottomPadding:10 height:20];
    
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    
    //TODO TODO TODO load page....
    /*
    
    [_swipeView scrollToItemAtIndex:incomingIndex duration:0.01f];
    
    
    */
    
    
    
    
    int incoming = (int)[defaults integerForKey:@"selectedIndex"];
    if (incoming==0) {
        //[_swipeView reloadItemAtIndex:0];
        isLoading = NO;
        isLoadingSecond = NO;
    }else{
        isLoading = NO;
        isLoadingSecond = NO;
        [_swipeView scrollToItemAtIndex:incoming duration:0.1f];
        //[_swipeView scrollToPage:incoming duration:0.1f];
    }
    
    
    
    
}

- (void)loadMap{
    
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return [incomingItems count];
}

//- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(CustomSwipeview *)view
{
    
    
    //code to nill all IBOutlets
    
    //IBOUtlet *something = [Something new]; etc etc
    
    //view.titleLabel = nil;
    
    
//    //create new view if no view is available for recycling
    
    if (view == nil)
    {
//        //don't do anything specific to the index within
//        //this `if (view == nil) {...}` statement because the view will be
//        //recycled and used with other index values later
        

        view = [[[NSBundle mainBundle]
                         loadNibNamed:@"SwipeView"
                         owner:self options:nil]
                        firstObject];
        view.bounds = self.swipeView.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
//        if (mapEnabled) {
//            
//            
//            
//            view.mainMap.zoomEnabled = YES;
//            view.mainMap.scrollEnabled = YES;
//            view.mainMap.userInteractionEnabled = YES;
//            //view.backGroundImage.alpha = 0.0f;
//            view.backGroundImage.alpha = 0.9f;
//            
//            view.weatherContainerView.hidden = NO;
//            view.resultContainerView.hidden = NO;
//            view.titleContainerView.hidden = NO;
//
//            [UIView beginAnimations:@"fadeInMapView" context:NULL];
//            [UIView setAnimationDuration:1.0];
//            view.backGroundImage.alpha = 0.0f;
//
//            view.weatherContainerView.hidden = YES;
//            view.resultContainerView.hidden = YES;
//            view.titleContainerView.hidden = YES;
//
//            [UIView commitAnimations];
//            isLoadingSecond = YES;
//
//        }else{
            view.mainMap.zoomEnabled = NO;
            view.mainMap.scrollEnabled = NO;
            view.mainMap.userInteractionEnabled = NO;
//            
            //view.backGroundImage.alpha = 0.0f;
//            
//            view.weatherContainerView.hidden = YES;
//            view.resultContainerView.hidden = YES;
//            view.titleContainerView.hidden = YES;
//            
//            
            //[UIView beginAnimations:@"fadeOutMapView" context:NULL];
            //[UIView setAnimationDuration:1.0];
//            
            view.backGroundImage.alpha = 0.9f;
//            
//            view.weatherContainerView.hidden = NO;
//            view.resultContainerView.hidden = NO;
//            view.titleContainerView.hidden = NO;
//            
//            [UIView commitAnimations];
//        }

        
        
        
//        if (!isLoading && !isLoadingSecond) {
//            isLoading = YES;
//        }else if (isLoading && !isLoadingSecond){
//            view.alpha = 0.0f;
//            [UIView beginAnimations:@"fadeInSecondView" context:NULL];
//            [UIView setAnimationDuration:1.0];
//            view.alpha = 1.0f;
//            [UIView commitAnimations];
//            isLoadingSecond = YES;
//        }
        
        
        
    }
    else
    {
//        //get a reference to the label in the recycled view
        
        
//        label = (UILabel *)[view viewWithTag:1];
//        cfsLabel = (UILabel *)[view viewWithTag:2];
//        meanLabel = (UILabel *)[view viewWithTag:21];
//..............
    }
//    
//
//    //set item label
//    //remember to always set any properties of your carousel item
//    //views outside of the `if (view == nil) {...}` check otherwise
//    //you'll get weird issues with carousel item content appearing
//    //in the wrong place in the carousel
//    
//
    NSDictionary *stationDict = incomingItems[index];

//    NSDictionary *locationDictionary;
//    locationArray = [defaults objectForKey:@"locationArray"];
//    for (NSDictionary *holderDict in locationArray) {
//        if ([stationDict[@"stationNumber"] isEqualToString:holderDict[@"stationNumber"]]) {
//            locationDictionary = holderDict;
//        }
//    }
    
    CLLocationCoordinate2D stationLocation;
    stationLocation.longitude = (CLLocationDegrees) [stationDict[@"longTotal"] doubleValue];
    stationLocation.latitude = (CLLocationDegrees) [stationDict[@"latTotal"] doubleValue];
    
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(stationLocation, 5*METERS_PER_MILE, 5*METERS_PER_MILE);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:stationLocation addressDictionary:nil];
    
    //    mapView.mapType = MKMapTypeHybrid;
    view.mainMap.centerCoordinate = stationLocation;
    
    [view.mainMap setDelegate:self];
    
    [view.mainMap setMapType:MKMapTypeHybrid];
    
    //
    
    //if (!mapEnabled) {
        [view.mainMap addAnnotation:placemark];
        //
        [view.mainMap setRegion:viewRegion animated:YES];
    //}
    
    
    //[view.mainMap setRegion:viewRegion animated:NO];
    
    //view.mainMap.alpha = 0.0f;
    
    
    
    
    
//
    NSDictionary *titleDict = stationDict[@"cleanedTitle"];
    view.titleLabel.text = titleDict[@"nameHolder"];
    view.titleLabel.alpha = 0.0f;
    view.subTitleLabel.text = titleDict[@"locationHolder"];
    view.subTitleLabel.alpha = 0.0f;
    

    
    NSDictionary *resultDict;
    for (NSDictionary *loopDict in resultArray) {
        if ([stationDict[@"stationNumber"] isEqualToString:loopDict[@"siteNumber"]]) {
            view.resultLabel.text = loopDict[@"siteValue"];
            resultDict = loopDict;
        }
    }
    
    NSMutableAttributedString *string = [NSMutableAttributedString new];
//
    view.resultLabel.alpha = 0.0f;
    for (NSDictionary *meanDict in minMaxArray) {
        if ([meanDict[@"siteNumber"] isEqualToString:resultDict[@"siteNumber"]]) {
            if ([resultDict[@"siteValue"] isEqualToString:@"Ssn"] || [resultDict[@"siteValue"] isEqualToString:@"Dis"] || [resultDict[@"siteValue"] isEqualToString:@"Ice"]) {
                view.resultLabel.text = @"Ice";
//                string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"regular historical average is %@",meanDict[@"meanValue"]]];
//                [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,7)];
                [view.resultLabel setTextColor:[UIColor whiteColor]];
            }else{
                if ([resultDict[@"siteValue"] doubleValue] < [meanDict[@"25Value"] doubleValue]) {
                    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"low historical average is %@",meanDict[@"meanValue"]]];
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.93 green:0.39 blue:0.25 alpha:1.0] range:NSMakeRange(0,3)];
                    [view.resultLabel setTextColor:[UIColor colorWithRed:0.93 green:0.39 blue:0.25 alpha:1.0]];
                    
                }else if ([resultDict[@"siteValue"] doubleValue] > [meanDict[@"75Value"] doubleValue]) {
                    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"high historical average is %@",meanDict[@"meanValue"]]];
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.15 green:0.58 blue:1.00 alpha:1.0] range:NSMakeRange(0,4)];
                    [view.resultLabel setTextColor:[UIColor colorWithRed:0.15 green:0.58 blue:1.00 alpha:1.0]];
                    
                    
                }else{
                    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"normal historical average is %@",meanDict[@"meanValue"]]];
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.42 green:0.91 blue:0.46 alpha:1.0] range:NSMakeRange(0,6)];
                    [view.resultLabel setTextColor:[UIColor colorWithRed:0.42 green:0.91 blue:0.46 alpha:1.0]];
                    
                }
            }
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    [view.averageLabel setAttributedText:string];
    
    

//   // NSDictionary @weatherDict = weatherCacheArray[index];
//    
//    
//    //for (int i=0; i<weatherCacheArray.count; i++) {
    if (weatherCacheArray.count>0) {
        
        NSMutableArray *innerArray;
        
        for (NSMutableArray *holderArray in weatherCacheArray) {
            //NSMutableArray *tempArray = [holderArray firstObject];
            NSDictionary *tempDict = [holderArray firstObject];
            //NSString *holder = [NSString stringWithFormat:@"%@", tempDict[@"cityId"]];
            if (stationDict[@"weatherStationId"] == tempDict[@"cityId"]) {
                innerArray = holderArray;
                //NSLog(@"set holder here: %i ", holderArray);
            }
        }
        
//        view.weatherOneResultLabel.alpha = 0.0f;
//        view.weatherOneDateLabel.alpha = 0.0f;
//        view.weatherOneImageView.alpha = 0.0f;
//        
//        view.weatherTwoResultLabel.alpha = 0.0f;
//        view.weatherTwoImageView.alpha = 0.0f;
//        view.weatherTwoDateLabel.alpha = 0.0f;
//        
//        view.weatherThreeResultLabel.alpha = 0.0f;
//        view.weatherThreeImageView.alpha = 0.0f;
//        view.weatherThreeDateLabel.alpha = 0.0f;
//        
//        view.weatherSeperatorOne.alpha = 0.0f;
//        view.weatherSeperatorThree.alpha = 0.0f;
        
        
        
        for (int i=0; i<innerArray.count; i++) {
            NSDictionary *weatherDict = innerArray[i];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setMaximumFractionDigits:0];
            switch (i) {
                case 0:
                {
                    NSMutableAttributedString *hiAttrString = [NSMutableAttributedString new];
                    hiAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@° ", [formatter stringFromNumber:weatherDict[@"highNum"]]]];
                    [hiAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,hiAttrString.length)];
                    
                    NSMutableAttributedString *loAttrString = [NSMutableAttributedString new];
                    loAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@°", [formatter stringFromNumber:weatherDict[@"lowNum"]]]];
                    [loAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0] range:NSMakeRange(0,loAttrString.length)];
                    
                    [hiAttrString appendAttributedString:loAttrString];
                    
                    //switch to attributed string
                    //[view.weatherOneResultLabel setText:[NSString stringWithFormat:@"%@° %@°",maxString, minString]];
                    [view.weatherOneResultLabel setAttributedText:hiAttrString];
                    [view.weatherOneImageView setImage:[UIImage imageNamed:weatherDict[@"iconString"]]];
                    [view.weatherOneDateLabel setText:@"Today"];
                    
                }
                    break;
                case 1:
                {
                    //[_fDateTwoLabel setText:dateString];
                    //[_fDetailTwoLabel setText:weatherDict[@"main"]];
                    NSMutableAttributedString *hiAttrString = [NSMutableAttributedString new];
                    hiAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@° ", [formatter stringFromNumber:weatherDict[@"highNum"]]]];
                    [hiAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,hiAttrString.length)];
                    
                    NSMutableAttributedString *loAttrString = [NSMutableAttributedString new];
                    loAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@°", [formatter stringFromNumber:weatherDict[@"lowNum"]]]];
                    [loAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0] range:NSMakeRange(0,loAttrString.length)];
                    
                    [hiAttrString appendAttributedString:loAttrString];
                    
                    //switch to attributed string
                    [view.weatherTwoResultLabel setAttributedText:hiAttrString];
                    [view.weatherTwoImageView setImage:[UIImage imageNamed:weatherDict[@"iconString"]]];
                    [view.weatherTwoDateLabel setText:[NSString stringWithFormat:@"%@", weatherDict[@"dateString"]]];
                }
                    break;
                case 2:
                {
                    //[_fDateThreeLabel setText:dateString];
                    //[_fDetailThreeLabel setText:weatherDict[@"main"]];
                    NSMutableAttributedString *hiAttrString = [NSMutableAttributedString new];
                    hiAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@° ", [formatter stringFromNumber:weatherDict[@"highNum"]]]];
                    [hiAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,hiAttrString.length)];
                    
                    NSMutableAttributedString *loAttrString = [NSMutableAttributedString new];
                    loAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@°", [formatter stringFromNumber:weatherDict[@"lowNum"]]]];
                    [loAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0] range:NSMakeRange(0,loAttrString.length)];
                    
                    [hiAttrString appendAttributedString:loAttrString];
                    
                    //switch to attributed string
                    [view.weatherThreeResultLabel setAttributedText:hiAttrString];
                    
                    [view.weatherThreeImageView setImage:[UIImage imageNamed:weatherDict[@"iconString"]]];
                    [view.weatherThreeDateLabel setText:[NSString stringWithFormat:@"%@", weatherDict[@"dateString"]]];
                }
                    break;
                    
                default:
                    break;
            }
        }

    }
//
//    
//         
//
//    
//    
//    //NSDictionary *locationDictionary = locationArray[index];
    
//
    [UIView beginAnimations:@"fadew1r" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherOneResultLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew1d" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherOneDateLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew1i" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherOneImageView.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew2t" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherTwoResultLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew2i" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherTwoImageView.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew2d" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherTwoDateLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew3r" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherThreeResultLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew3i" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherThreeImageView.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadew3d" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherThreeDateLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadews1" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherSeperatorOne.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadews3" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.weatherSeperatorThree.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadeTitle" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.titleLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadeSubtitle" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.subTitleLabel.alpha = 1.0f;
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"fadeResult" context:NULL];
    [UIView setAnimationDuration:1.0];
    view.resultLabel.alpha = 1.0f;
    [UIView commitAnimations];
    


    
    return view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for(MKPinAnnotationView *eachView in views) {
        //[eachView setAnimatesDrop:YES];
        
        eachView.pinTintColor = [UIColor colorWithRed:0.15 green:0.56 blue:1.00 alpha:1.0];
        //eachView.image = [UIImage imageNamed:@"GreyMapIcon.png"];
        //[eachView setPinColor:MKPinAnnotationColorGreen];
    }
}

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
//    
//    
//        
////        MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
////        //annView.pinColor = MKPinAnnotationColorRed;
////        //annView.animatesDrop = YES;
////        //annView.canShowCallout = YES;
////        annView.image = [UIImage imageNamed:@"GreyMapIcon.png"];
////        return annView;
//    
//    
//    
//    MKAnnotationView *pinView = nil;
//    if(annotation != mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"com.invasivecode.pin";
//        pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil )
//            pinView = [[MKAnnotationView alloc]
//                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//        
//        //pinView.pinColor = MKPinAnnotationColorGreen;
//        //pinView.canShowCallout = YES;
//        //pinView.animatesDrop = YES;
//        //pinView.image = [UIImage imageNamed:@"BlueMapIcon.png"];    //as suggested by Squatch
//    }
//    else {
//        [mapView.userLocation setTitle:@"I am here"];
//    }
//    return pinView;
//    
//    
//    
//}


- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

//- (IBAction)changePage:(id)sender {
-(void)changePage:(UIPageControl*)control{
    //UIPageControl *control=sender;
    NSLog(@"page clicked %li", (long)control.currentPage);
    [_swipeView scrollToItemAtIndex:control.currentPage duration:0.01f];
//    int page = pager.currentPage;
//    CGRect frame = imageGrid_scrollView.frame;
//    frame.origin.x = frame.size.width * page;
//    frame.origin.y = 0;
//    [imageGrid_scrollView scrollRectToVisible:frame animated:YES];
}

- (void) backClickedPage:(id)sender{
    NSLog(@"back");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mapClicked:(id)sender{
    
    if (!mapEnabled) {
        
        UIView *v = [self.view viewWithTag:1001];
        [v removeFromSuperview];
        
        UIButton *Button = [self.view viewWithTag:1002];
        [Button setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        
        CustomSwipeview *view = [_swipeView itemCustomViewAtIndex:pageControl.currentPage];
        
        mapEnabled = YES;
        
        view.mainMap.zoomEnabled = YES;
        view.mainMap.scrollEnabled = YES;
        view.mainMap.userInteractionEnabled = YES;
        
        view.backGroundImage.alpha = 0.9f;
        
        view.weatherContainerView.hidden = NO;
        view.resultContainerView.hidden = NO;
        view.titleContainerView.hidden = NO;
        pageControl.hidden = NO;
        view.weatherContainerView.alpha =1.0f;
        view.resultContainerView.alpha = 1.0f;
        view.titleContainerView.alpha = 1.0f;
        pageControl.alpha = 1.0f;
        
        
        [UIView beginAnimations:@"fadeOutMapView" context:NULL];
        [UIView setAnimationDuration:1.0];
        
        
        view.backGroundImage.alpha = 0.0f;
        view.weatherContainerView.alpha =0.0f;
        view.resultContainerView.alpha = 0.0f;
        view.titleContainerView.alpha = 0.0f;
        pageControl.alpha = 0.0f;
        pageControl.hidden = YES;
        view.weatherContainerView.hidden = YES;
        view.resultContainerView.hidden = YES;
        view.titleContainerView.hidden = YES;
        
        
        [UIView commitAnimations];
        
    }else{
        
        
        backButton = [[UIButton alloc] init];
        [backButton setTag:1001];
        [backButton setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backButton];
        [backButton anchorTopLeftWithLeftPadding:0 topPadding:27 width:50 height:50];
        UIImage *backArrow = [UIImage imageNamed:@"BackIcon"];
        [backButton setImage:backArrow forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backClickedPage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *Button = [self.view viewWithTag:1002];
        [Button setImage:[UIImage imageNamed:@"GreyMapIcon"] forState:UIControlStateNormal];
        
        CustomSwipeview *view = [_swipeView itemCustomViewAtIndex:pageControl.currentPage];
        
        mapEnabled = NO;
        
        view.mainMap.zoomEnabled = NO;
        view.mainMap.scrollEnabled = NO;
        view.mainMap.userInteractionEnabled = NO;
        //view.backGroundImage.alpha = 0.0f;
        view.backGroundImage.alpha = 0.0f;
        
        view.weatherContainerView.alpha =0.0f;
        view.resultContainerView.alpha = 0.0f;
        view.titleContainerView.alpha = 0.0f;
        pageControl.alpha = 0.0f;
        pageControl.hidden = YES;
        view.weatherContainerView.hidden = YES;
        view.resultContainerView.hidden = YES;
        view.titleContainerView.hidden = YES;
        
        [UIView beginAnimations:@"fadeInMapView" context:NULL];
        [UIView setAnimationDuration:1.0];
        view.backGroundImage.alpha = 0.9f;
        
        view.weatherContainerView.alpha =1.0f;
        view.resultContainerView.alpha = 1.0f;
        view.titleContainerView.alpha = 1.0f;
        pageControl.alpha = 1.0f;
        pageControl.hidden = NO;
        view.weatherContainerView.hidden = NO;
        view.resultContainerView.hidden = NO;
        view.titleContainerView.hidden = NO;
        
        [UIView commitAnimations];
        
    }
    
    //[_swipeView reloadData];
}
- (void)swipeViewDidEndScrollingAnimation:(SwipeView *)swipeView{
    NSLog(@"did end");
    pageControl.currentPage = swipeView.currentPage;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView{
    NSLog(@"did scroll");
    pageControl.currentPage = swipeView.currentPage;
}


@end
