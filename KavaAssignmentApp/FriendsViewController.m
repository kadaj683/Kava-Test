//
//  FriendsViewController.m
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "FriendsViewController.h"
#import "FacebookSDK/FacebookSDK.h"

@interface FriendsViewController ()


@end

@implementation FriendsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        
    }
    return self;
}


/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.delegate = self;
    if (!FBSession.activeSession.isOpen) {
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
            switch (state) {
                case FBSessionStateClosedLoginFailed:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:error.localizedDescription
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                    break;
                default:
                    break;
            }
        }];
    }
    self.userID = [UserStoredDataViewController info].id;
    self.allowsMultipleSelection = NO;
    [self loadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void) friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    if ([self.selection count]>0) {
        id<FBGraphUser> user = self.selection[0];
        
        
        //NSString *format = @"fb://profile/%@";
        NSString *format = @"https://facebook.com/%@";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:format,[user id]]]];
        
    }
    
}



@end
