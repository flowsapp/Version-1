//
//  AddStationViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "AddStationViewController.h"
#import "GDIIndexBar.h"
#import "AddDetailViewController.h"
#import "UIColor+Hexadecimal.h"

@interface AddStationViewController () <UITableViewDataSource, UITableViewDelegate, GDIIndexBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation AddStationViewController{
    BOOL isInState;
    NSMutableArray *alphabetsArray;
    NSMutableArray *riverAlphabetsArray;
    NSMutableArray *stateHolder;
    NSMutableArray *queryHolder;
    NSMutableArray *sortedDetailForTable;
    GDIIndexBar *indexBar;
    NSString *stateToPass;
    NSString *longStateToPass;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [self.mainTable setSeparatorColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    label.textColor = [UIColor whiteColor];
    label.text = @"Add Station";
    
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = label;
    
    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0], NSForegroundColorAttributeName: [UIColor colorWithHex:@"ACACAC"]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    
    //self.navigationItem.title = @"Add Station";
    
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     @{NSForegroundColorAttributeName:[UIColor colorWithHex:@"ACACAC"]}];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
//    [self.navigationController.navigationItem.backBarButtonItem setBackgroundVerticalPositionAdjustment:-50 forBarMetrics:UIBarMetricsDefault];
    
    _mainTable.tableFooterView = [UIView new];
    
//    float my_offset_plus_or_minus = -20.0f;
//    
//    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"Back"
//                                                              style:UIBarButtonItemStylePlain
//                                                             target:self action:@selector(backClicked:)];
//    
//    [item setBackgroundVerticalPositionAdjustment:my_offset_plus_or_minus forBarMetrics:UIBarMetricsDefault];
//    self.navigationItem.leftBarButtonItem = item;
    
    stateHolder = [[NSMutableArray alloc] initWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Dist. of Columbia", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Puerto Rico", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil];
    queryHolder = [[NSMutableArray alloc] initWithObjects:@"al", @"ak", @"az", @"ar", @"ca", @"co", @"ct", @"de", @"dc", @"fl", @"ga", @"hi", @"id", @"il", @"in", @"ia", @"ks", @"ky", @"la", @"me", @"md", @"ma", @"mi", @"mn", @"mt", @"ne", @"nv", @"nh", @"nm", @"ny", @"nc", @"nd", @"oh", @"ok", @"or", @"pa", @"pr", @"ri", @"sc", @"sd", @"tn", @"tx", @"ut", @"vt", @"va", @"wa", @"wv", @"wi", @"wy", nil];
    
    //riverAlphabetsArray = [[NSMutableArray alloc] init];
    alphabetsArray = [[NSMutableArray alloc] init];
    [self createAlphabetArray];
    
    [_mainTable setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    indexBar = [[GDIIndexBar alloc] initWithTableView:_mainTable];
    //[[GDIIndexBar appearance] setTextColor:[UIColor blackColor]];
    [[GDIIndexBar appearance] setTextColor:[UIColor colorWithHex:@"ACACAC"]];
    //[[GDIIndexBar appearance] setTextShadowColor:[UIColor grayColor]];
    [[GDIIndexBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[GDIIndexBar appearance] setBarBackgroundColor:[UIColor clearColor]];
    indexBar.textFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:13.0f];
    //[[GDIIndexBar appearance] setBarBackgroundColor:[UIColor blueColor]];
    indexBar.delegate = self;
    [indexBar setTextOffset:UIOffsetMake(5.0, 0.0)];
    [self.view addSubview:indexBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked:(id)sender{
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"back clicked");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.alpha = 1.0f;
    
//    [UIView beginAnimations:@"fadeResult" context:NULL];
//    [UIView setAnimationDuration:0.1];
//    self.navigationController.navigationBar.alpha = 1.0f;
//    [UIView commitAnimations];
    
    
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return alphabetsArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        //return stateHolder.count;
    NSArray *sectionArray = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:section]]];
    return sectionArray.count;
    
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
    static NSString *CellIdentifier = @"addCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSArray *sectionArray = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
    //cell.textLabel.text = [sectionArray objectAtIndex:indexPath.row];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};//[UIColor colorWithHex:@"ACACAC"]};
    
    NSAttributedString *cellString = [[NSAttributedString alloc] initWithString:[sectionArray objectAtIndex:indexPath.row] attributes:attributes];
    
    [cell.textLabel setAttributedText:cellString];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = [queryHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
    NSArray *stateNameArray = [stateHolder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [alphabetsArray objectAtIndex:indexPath.section]]];
    stateToPass = [sectionArray objectAtIndex:indexPath.row];
    longStateToPass= [stateNameArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"stationDetailView" sender:self];
}

#pragma mark - index bar


- (NSUInteger)numberOfIndexesForIndexBar:(GDIIndexBar *)indexBar
{
    
    return alphabetsArray.count;
    
    
}

- (NSString *)stringForIndex:(NSUInteger)index
{
    return [alphabetsArray objectAtIndex:index];
}

- (void)indexBar:(GDIIndexBar *)indexBar didSelectIndex:(NSUInteger)index
{
    [_mainTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
}

#pragma mark - data prep

#pragma mark - Create Alphabet Array
- (void)createAlphabetArray {
    [alphabetsArray removeAllObjects];
    //NSMutableArray *tempFirstLetterArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [stateHolder count]; i++) {
        NSString *letterString = [[stateHolder objectAtIndex:i] substringToIndex:1];
        if (![alphabetsArray containsObject:letterString]) {
            [alphabetsArray addObject:letterString];
        }
    }
    //alphabetsArray = tempFirstLetterArray;
    
}


- (IBAction)cancelClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddDetailViewController *vc = [segue destinationViewController];
    [vc setIncomingValue:stateToPass];
    [vc setSelectedState:longStateToPass];
}

//- (IBAction)backClicked:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


@end
