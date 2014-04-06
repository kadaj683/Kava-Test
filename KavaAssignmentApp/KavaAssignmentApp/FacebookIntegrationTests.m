//
//  FacebookIntegrationTests.m
//  KavaAssignmentApp
//
//  Created by kadaj on 4/4/14.
//  Copyright (c) 2014 kadaj. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FacebookSDK/FacebookSDK.h"
#import "UserInfoViewController.h"
#import "UserInfoViewController+Testing.h"
#import "UserStoredDataViewController.h"
#import "UserStoredDataViewController+Testing.h"
#import "UserInfoTest.h"
#import "AppDelegate.h"
#import "OCMock/OCMock.h"

@interface FacebookIntegrationTests : XCTestCase

@property UserInfoViewController *controller;
@property id controllerMock;

@end

@implementation FacebookIntegrationTests

static const int kConnectionTimeOut = 3;

typedef enum {
    kConnectionTestStateNone = 1<<0,
    kConnectionTestStateUp = 1<<1,
    kConnectionTestStateDown = 1<<2,
    kConnectionTestStateTimedOut = 1<<3
} ConnectionTestState;

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

- (void) internetConnectionForIp:(NSString *) ip withCallback:(void(^)(ConnectionTestState)) callback
{
    __block BOOL finished = NO;
    __block ConnectionTestState state = kConnectionTestStateNone;
    [self.controller prepareInternetConnectionForIP:ip withHandler:^(BOOL result){
        if (result) {
            state |= kConnectionTestStateUp;
        } else {
            state |= kConnectionTestStateDown;
        }
        
        finished = YES;
        
    }];
    
    int reruns = kConnectionTimeOut;
    while (!finished && reruns) {
        [[NSRunLoop mainRunLoop] runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:1]];
        reruns--;
    }
    
    if (!finished && !reruns) {
        state |= kConnectionTestStateTimedOut;
    }
    callback(state);
    
}

- (void) testPrepareInternetConnectionForIPWhenOnline
{
    [self internetConnectionForIp:@"127.0.0.1" withCallback:^(ConnectionTestState state) {
        if (state & kConnectionTestStateTimedOut) {
            XCTFail("Connection test times out for online connection");
        } else if ((state == kConnectionTestStateNone) || (state & kConnectionTestStateDown) || !(state & kConnectionTestStateUp)) {
            XCTFail("Gives offline for online connection");
        }
    }];
}

- (void) testFacebookLoginUIOnFirstTime
{

    [[[self.controllerMock stub] andReturnValue:OCMOCK_VALUE(NO)] facebookDataFetched];
    [[[self.controllerMock stub] ignoringNonObjectArgs] setFacebookDataFetched:YES];
  
    [[[self.controllerMock expect] ignoringNonObjectArgs] presentViewController:[OCMArg checkWithBlock:^BOOL(id object){
        return [object isKindOfClass:[FBUserSettingsViewController class]];
    }] animated:NO completion:OCMOCK_ANY];
    [self.controller viewDidLoad];
    [self.controllerMock verify];
    
}



- (void) testLoginViewControllerDidLogUserInDownloadsData {
    [[[self.controllerMock stub] andReturnValue:OCMOCK_VALUE(NO)] facebookDataFetched];
    [[[self.controllerMock stub] ignoringNonObjectArgs] setFacebookDataFetched:YES];
    
    [[self.controllerMock expect] facebookFetch:OCMOCK_ANY onError:OCMOCK_ANY];
    id settingsMock = [OCMockObject niceMockForClass:[FBUserSettingsViewController class]];
    [self.controller loginViewControllerDidLogUserIn:settingsMock];
    [self.controllerMock verify];
}

- (void) testLoginViewControllerDidLogUserInUpdatesData {
    [[[self.controllerMock stub] andReturnValue:OCMOCK_VALUE(NO)] facebookDataFetched];
    [[[self.controllerMock stub] ignoringNonObjectArgs] setFacebookDataFetched:YES];
    
    [[self.controllerMock expect] fetchData];
    id settingsMock = [OCMockObject niceMockForClass:[FBUserSettingsViewController class]];
    [self.controller loginViewControllerDidLogUserIn:settingsMock];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:7]];
    [self.controllerMock verify];
}







@end
