//
//  CustomSwipeview.h
//  newFlows
//
//  Created by Matt Riddoch on 2/29/16.
//  Copyright © 2016 Matt Riddoch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CustomSwipeview : UIView


@property (weak, nonatomic) IBOutlet MKMapView *mainMap;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;


//top container

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;


//result container

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UILabel *cfsLabel;


//weather container

//weather one
@property (weak, nonatomic) IBOutlet UILabel *weatherOneDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherOneImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherOneResultLabel;


@property (weak, nonatomic) IBOutlet UILabel *weatherTwoDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherTwoImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherTwoResultLabel;


@property (weak, nonatomic) IBOutlet UILabel *weatherThreeDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherThreeImageView;
@property (weak, nonatomic) IBOutlet UILabel *weatherThreeResultLabel;


@property (weak, nonatomic) IBOutlet UIView *mainContainerView;

@property (weak, nonatomic) IBOutlet UIView *weatherOneContainer;
@property (weak, nonatomic) IBOutlet UIView *weatherTwoContainer;
@property (weak, nonatomic) IBOutlet UIView *weatherThreeContainer;

@property (weak, nonatomic) IBOutlet UIView *weatherSeperatorOne;
@property (weak, nonatomic) IBOutlet UIView *weatherSeperatorThree;

//container views

@property (weak, nonatomic) IBOutlet UIView *weatherContainerView;
@property (weak, nonatomic) IBOutlet UIView *resultContainerView;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;


@end
