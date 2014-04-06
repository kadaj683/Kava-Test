//
//  UserInfo.h
//  KavaAssignmentApp
//
//  Created by kadaj on 4/6/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UserInfoTest.h"

@interface UserInfo : NSManagedObject<UserInfoTest>

@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * contacts;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * id;

@end
