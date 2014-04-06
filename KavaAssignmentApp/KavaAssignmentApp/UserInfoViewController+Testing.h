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


- (void)leaveEditMode;
- (BOOL)inputInfoToObject:(UserInfo *)info withError:(NSError* __autoreleasing *) error;
- (void)enterEditMode;
- (void)fillInfoFromObject: (UserInfo *) info;

@end
