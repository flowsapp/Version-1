//
//  AddStationViewController.m
//  newFlows
//
//  Created by Matt Riddoch on 9/25/15.
//  Copyright © 2015 Matt Riddoch. All rights reserved.
//

#import "InfoViewController.h"
//#import "GDIIndexBar.h"
//#import "AddDetailViewController.h"
#import "UIColor+Hexadecimal.h"
//#import "iRate.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "infoCell.h"


@interface InfoViewController () <MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource >

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIView *highView;
@property (weak, nonatomic) IBOutlet UIView *normalView;
@property (weak, nonatomic) IBOutlet UIView *lowView;

@end

@implementation InfoViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderLogo"]];
    self.navigationItem.titleView = img;
    
    [self.mainTable setSeparatorColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0]];
    
    
    _highView.layer.cornerRadius = 10;
    [_highView setBackgroundColor:[UIColor colorWithRed:0.15 green:0.58 blue:1.00 alpha:1.0]];
    _normalView.layer.cornerRadius = 10;
    [_normalView setBackgroundColor:[UIColor colorWithRed:0.42 green:0.91 blue:0.46 alpha:1.0]];
    _lowView.layer.cornerRadius = 10;
    [_lowView setBackgroundColor:[UIColor colorWithRed:0.93 green:0.39 blue:0.25 alpha:1.0]];
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
//    label.backgroundColor = [UIColor clearColor];
//    label.numberOfLines = 0;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
//    label.textColor = [UIColor whiteColor];
//    label.text = @"Add Station";
//    
//    [self.navigationItem.titleView sizeToFit];
//    self.navigationItem.titleView = label;
//    
//    NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0], NSForegroundColorAttributeName: [UIColor colorWithHex:@"ACACAC"]};
//    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked:(id)sender{
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
    NSLog(@"back clicked");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.alpha = 1.0f;
    
//    [UIView beginAnimations:@"fadeResult" context:NULL];
//    [UIView setAnimationDuration:0.1];
//    self.navigationController.navigationBar.alpha = 1.0f;
//    [UIView commitAnimations];
    
    
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
    return 2;
    //}
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    return 66.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"infoCell";
    infoCell *cell = [_mainTable dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.textLabel.text = @"title";
    cell.mainLabel.textAlignment = NSTextAlignmentCenter;
    //cell.mainLabel.textColor = [UIColor whiteColor];
    
    NSString *titleString;
    
    if (indexPath.row == 0) {
        titleString = @"Send Feedback";
    }else{
        titleString = @"Disclaimer & Restore";
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"ACACAC"]};//[UIColor colorWithHex:@"ACACAC"]};
    NSAttributedString *cellString = [[NSAttributedString alloc] initWithString:titleString attributes:attributes];
    
    cell.mainLabel.attributedText = cellString;
    
    return cell;
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.5f;
    
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    view.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self feedbackClicked];
    }else{
        [self performSegueWithIdentifier:@"disclaimerSegue" sender:self];
    }
}



#pragma mark - IBActions

- (IBAction)disclaimerClicked:(id)sender {
    [self performSegueWithIdentifier:@"disclaimerSegue" sender:self];
}

- (IBAction)ratingClicked:(id)sender {
    //[iRate sharedInstance].ratedThisVersion = YES;
    //[[iRate sharedInstance] openRatingsPageInAppStore];
    
    //[[iRate sharedInstance] promptForRating];
}
- (void)feedbackClicked{
#pragma mark - Mail
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"garrett@flowsapp.com", nil];
        [mailer setToRecipients:toRecipients];
        [mailer setSubject:@"Flows App Feedback"];
        //NSString *emailBody = @"body here";
        //[mailer setMessageBody:emailBody isHTML:YES];
        mailer.mailComposeDelegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        //[self presentModalViewController:mailer animated:YES];
        [self presentViewController:mailer animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error title"
                                                        message:@"error message"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [controller dismissViewControllerAnimated:YES completion:^{
//        [iRate sharedInstance].ratedThisVersion = YES;
//        _isShowed = NO;
//        [self.view removeFromSuperview];
    }];
    
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

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
