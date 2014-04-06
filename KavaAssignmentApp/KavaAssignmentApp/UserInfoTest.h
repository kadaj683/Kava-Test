//
//  UserInfoTest.h
//  KavaAssignmentApp
//
//  Created by kadaj on 3/31/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserInfoTest <NSObject>

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * contacts;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSString * id;

@end
