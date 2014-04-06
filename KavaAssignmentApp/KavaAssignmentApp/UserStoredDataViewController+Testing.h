//
//  UserStoredDataViewController+Testing.h
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import "UserStoredDataViewController.h"

@interface UserStoredDataViewController (Testing)

@property AppDelegate *appDelegate;
@property NSManagedObjectContext *managedObjectContext;
@property BOOL facebookDataFetched;

@property UserInfo *info;

- (void) facebookFetch: (void (^) (void)) successHandler onError: (void (^) (NSError *)) errorHandler;
- (void) prepareInternetConnectionForIP:(NSString *) ip withHandler:(void (^)(BOOL)) errorHandler;


@end
