//
//  UserInfoViewController+TestedMethods.h
//  KavaAssignmentApp
//
//  Created by kadaj on 3/31/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UserInfo.h"
#import "AppDelegate.h"

@interface UserInfoViewController (Testing)

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *birthday;
@property (weak, nonatomic) IBOutlet UITextView *contacts;
@property (weak, nonatomic) IBOutlet UITextView *bio;

@property AppDelegate *appDelegate;
@property NSManagedObjectContext *managedObjectContext;
@property BOOL facebookDataFetched;

@property UserInfo *info;

- (void) facebookFetch: (void (^) (void)) successHandler onError: (void (^) (NSError *)) errorHandler;
- (void) prepareInternetConnectionForIP:(NSString *) ip withHandler:(void (^)(BOOL)) errorHandler;
- (void) leaveEditMode;
- (void) enterEditMode;
- (void) fillInfo;
- (void) fetchData;

@end
