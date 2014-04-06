//
//  UserStoredDataViewControllerDelegate.h
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserStoredDataViewControllerDelegate <NSObject>
@optional
- (void)leaveEditMode;
- (void)enterEditMode;
- (BOOL)inputInfo: (NSError* __autoreleasing *) error;
- (void)fillInfo;

@end
