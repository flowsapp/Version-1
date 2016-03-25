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
#import "iRate.h"
#import <MessageUI/MessageUI.h>

@interface InfoViewController () <MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource >

@property (weak, nonatomic) IBOutlet UITableView *mainTable;

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

- (IBAction)disclaimerClicked:(id)sender {
    [self performSegueWithIdentifier:@"disclaimerSegue" sender:self];
}

- (IBAction)ratingClicked:(id)sender {
    [iRate sharedInstance].ratedThisVersion = YES;
    [[iRate sharedInstance] openRatingsPageInAppStore];
    
    //[[iRate sharedInstance] promptForRating];
}
- (IBAction)feedbackClicked:(id)sender {
#pragma mark - Mail
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"email here", nil];
        [mailer setToRecipients:toRecipients];
        [mailer setSubject:@"subject here"];
        NSString *emailBody = @"body here";
        [mailer setMessageBody:emailBody isHTML:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
