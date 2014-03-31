//
//  UserInfoViewControllerTests.m
//  KavaAssignmentApp
//
//  Created by kadaj on 3/30/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UserInfoViewController.h"
#import "UserInfoViewController+Testing.h"
#import "UserInfoTest.h"
#import "AppDelegate.h"
#import "OCMock/OCMock.h"
@interface UserInfoViewControllerTests : XCTestCase

@end

@implementation UserInfoViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testLeaveEditMode
{
    UserInfoViewController *controller = [[UserInfoViewController alloc] init];
    id image = [OCMockObject mockForClass:[UIImageView class]];
    id firstName = [OCMockObject mockForClass:[UITextField class]];
    id lastName = [OCMockObject mockForClass:[UITextField class]];
    id birthday = [OCMockObject mockForClass:[UITextField class]];
    id contacts = [OCMockObject mockForClass:[UITextView class]];
    id bio = [OCMockObject mockForClass:[UITextView class]];
    
    controller.image = image;
    controller.firstName = firstName;
    controller.lastName = lastName;
    controller.birthday = birthday;
    controller.contacts = contacts;
    controller.bio = bio;
    
    [[firstName expect] setEnabled:NO];
    [[lastName expect] setEnabled:NO];
    [[birthday expect] setEnabled:NO];
    [[contacts expect] setEditable:NO];
    [[bio expect] setEditable:NO];
    
    [controller leaveEditMode];
    
    [image verify];
    [firstName verify];
    [lastName verify];
    [birthday verify];
    [contacts verify];
    [bio verify];
}

- (void)testEnterEditMode
{
    UserInfoViewController *controller = [[UserInfoViewController alloc] init];
    id image = [OCMockObject mockForClass:[UIImageView class]];
    id firstName = [OCMockObject mockForClass:[UITextField class]];
    id lastName = [OCMockObject mockForClass:[UITextField class]];
    id birthday = [OCMockObject mockForClass:[UITextField class]];
    id contacts = [OCMockObject mockForClass:[UITextView class]];
    id bio = [OCMockObject mockForClass:[UITextView class]];
    
    controller.image = image;
    controller.firstName = firstName;
    controller.lastName = lastName;
    controller.birthday = birthday;
    controller.contacts = contacts;
    controller.bio = bio;
    
    [[firstName expect] setEnabled:YES];
    [[lastName expect] setEnabled:YES];
    [[contacts expect] setEditable:YES];
    [[bio expect] setEditable:YES];
    
    [controller enterEditMode];
    
    [image verify];
    [firstName verify];
    [lastName verify];
    [birthday verify];
    [contacts verify];
    [bio verify];
}

- (void) testFillInfo
{
    id userInfo = [OCMockObject mockForProtocol:@protocol(UserInfoTest)];
    [[userInfo expect] firstName];
    [[userInfo expect] lastName];
    [[userInfo expect] birthday];
    [[userInfo expect] avatar];
    [[userInfo expect] contacts];
    [[userInfo expect] bio];
    
    UserInfoViewController *controller = [[UserInfoViewController alloc] init];
    controller.info = userInfo;
    [controller fillInfo];
    
    [userInfo verify];
    
}

- (void) testFetchDataFirstTime
{
    id appDelegate = [OCMockObject mockForClass:[AppDelegate class]];
    id context = [OCMockObject niceMockForClass:[NSManagedObjectContext class]];
    id entity = [OCMockObject niceMockForClass:[NSEntityDescription class]];
    [[[[entity stub] classMethod] andReturn:nil] entityForName:OCMOCK_ANY inManagedObjectContext:context];
    [[[[entity stub] classMethod] andReturn:nil] insertNewObjectForEntityForName:OCMOCK_ANY inManagedObjectContext:context];
    NSArray *noResults = @[];
    [[[context stub] andReturn:noResults] executeFetchRequest:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    UserInfoViewController *controller = [UserInfoViewController alloc];
    id controllerMock = [OCMockObject partialMockForObject:controller];
    controller = [controller init];
    controller.appDelegate = appDelegate;
    controller.managedObjectContext = context;
    [[controllerMock expect] enterEditMode];
    [controller fetchData];
    [controllerMock verify];
}

- (void) testFetchDataOtherTimes
{
    id appDelegate = [OCMockObject mockForClass:[AppDelegate class]];
    id context = [OCMockObject niceMockForClass:[NSManagedObjectContext class]];
    id entity = [OCMockObject niceMockForClass:[NSEntityDescription class]];
    [[[[entity stub] classMethod] andReturn:nil] entityForName:OCMOCK_ANY inManagedObjectContext:context];
    id info = [OCMockObject niceMockForProtocol:@protocol(UserInfoTest)];
    NSArray *results = @[info];
    [[[context stub] andReturn:results] executeFetchRequest:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]];
    UserInfoViewController *controller = [UserInfoViewController alloc];
    id controllerMock = [OCMockObject partialMockForObject:controller];
    controller = [controller init];
    controller.appDelegate = appDelegate;
    controller.managedObjectContext = context;
    [[controllerMock expect] leaveEditMode];
    [controller fetchData];
    [controllerMock verify];
}

@end




