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
#import "UserStoredDataViewController.h"
#import "UserStoredDataViewController+Testing.h"
#import "UserInfoTest.h"
#import "AppDelegate.h"
#import "OCMock/OCMock.h"
@interface UserInfoViewControllerTests : XCTestCase

@property UserInfoViewController *controller;
@property id controllerMock;

@end

@implementation UserInfoViewControllerTests

- (void)setUp
{
    [super setUp];
    self.controller = [UserInfoViewController alloc];
    self.controllerMock = [OCMockObject partialMockForObject:self.controller];
    self.controller = [self.controller init];
    self.controller.delegate = self.controller;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testLeaveEditMode
{
    id image = [OCMockObject mockForClass:[UIImageView class]];
    id firstName = [OCMockObject mockForClass:[UITextField class]];
    id lastName = [OCMockObject mockForClass:[UITextField class]];
    id birthday = [OCMockObject mockForClass:[UITextField class]];
    id contacts = [OCMockObject mockForClass:[UITextView class]];
    id bio = [OCMockObject mockForClass:[UITextView class]];
    
    self.controller.image = image;
    self.controller.firstName = firstName;
    self.controller.lastName = lastName;
    self.controller.birthday = birthday;
    self.controller.contacts = contacts;
    self.controller.bio = bio;
    
    [[firstName expect] setEnabled:NO];
    [[lastName expect] setEnabled:NO];
    [[birthday expect] setEnabled:NO];
    [[contacts expect] setEditable:NO];
    [[bio expect] setEditable:NO];
    
    [self.controller leaveEditMode];
    
    [image verify];
    [firstName verify];
    [lastName verify];
    [birthday verify];
    [contacts verify];
    [bio verify];
}

- (void)testEnterEditMode
{
    id image = [OCMockObject mockForClass:[UIImageView class]];
    id firstName = [OCMockObject mockForClass:[UITextField class]];
    id lastName = [OCMockObject mockForClass:[UITextField class]];
    id birthday = [OCMockObject mockForClass:[UITextField class]];
    id contacts = [OCMockObject mockForClass:[UITextView class]];
    id bio = [OCMockObject mockForClass:[UITextView class]];
    
    self.controller.image = image;
    self.controller.firstName = firstName;
    self.controller.lastName = lastName;
    self.controller.birthday = birthday;
    self.controller.contacts = contacts;
    self.controller.bio = bio;
    
    [[firstName expect] setEnabled:YES];
    [[lastName expect] setEnabled:YES];
    [[contacts expect] setEditable:YES];
    [[bio expect] setEditable:YES];
    
    [self.controller enterEditMode];
    
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
    

    //self.controller.info = userInfo;
    [self.controller fillInfoFromObject:userInfo];
    
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

    self.controller.appDelegate = appDelegate;
    self.controller.managedObjectContext = context;
    [[self.controllerMock expect] enterEditMode];
    [self.controller fetchData];
    [self.controllerMock verify];
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

    self.controller.appDelegate = appDelegate;
    self.controller.managedObjectContext = context;
    [[self.controllerMock expect] leaveEditMode];
    [self.controller fetchData];
    [self.controllerMock verify];
}

- (void) testValidationOfEmptyName
{
    id fieldMock = [OCMockObject mockForClass:[UITextField class]];
    [[[fieldMock stub] andReturn:@""] text];
    self.controller.firstName = fieldMock;
    NSError *error;
    id info = [OCMockObject niceMockForProtocol:@protocol(UserInfoTest)];
    BOOL result = [self.controller inputInfoToObject:info withError:&error];
    if (result || (!result && !([error code] & 1))) {
        XCTFail("Validation failed");
    }
}

- (void) testValidationOfValidName
{
    id fieldMock = [OCMockObject mockForClass:[UITextField class]];
    [[[fieldMock stub] andReturn:@"John"] text];
    self.controller.firstName = fieldMock;
    NSError *error;
    id info = [OCMockObject niceMockForProtocol:@protocol(UserInfoTest)];
    BOOL result = [self.controller inputInfoToObject:info withError:&error];
    if (!result && !([error code] & 1)) {
        XCTFail("Validation failed");
    }

    
}

@end




