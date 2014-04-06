//
//  UserStoredDataViewController.h
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "UserStoredDataViewControllerDelegate.h"

@interface UserStoredDataViewController : UITableViewController<FBUserSettingsDelegate,NSURLSessionDataDelegate>

@property FBUserSettingsViewController *settings;
@property NSManagedObjectContext *managedObjectContext;
@property AppDelegate *appDelegate;
@property BOOL editMode;
@property (readonly) BOOL facebookDataFetched;
//@property UserInfo *info;

@property id<UserStoredDataViewControllerDelegate> delegate;

- (void)loginViewController:(id)sender receivedError:(NSError *)error;
- (void)loginViewControllerWillLogUserOut:(id)sender;
- (void)loginViewControllerDidLogUserOut:(id)sender;
- (void)loginViewControllerDidLogUserIn:(id)sender;

- (void)performEditing;
- (void)saveData;
- (void)fetchData;
- (void)showMessage:(NSString *)text withTitle:(NSString *)title;


@end


