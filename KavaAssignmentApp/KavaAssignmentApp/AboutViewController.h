//
//  AboutViewController.h
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "UserStoredDataViewController.h"

@interface AboutViewController : UserStoredDataViewController<UserStoredDataViewControllerDelegate>

- (void)leaveEditMode;
- (BOOL)inputInfo: (NSError* __autoreleasing *) error;
- (void)enterEditMode;
- (void)fillInfo;

@end
