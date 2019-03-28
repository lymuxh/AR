//
//  AR3DCustomerDemoUITests.m
//  AR3DCustomerDemoUITests
//
//  Created by muxiaohui on 2017/10/23.
//  Copyright © 2017年 lymuxh. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AR3DCustomerDemoUITests : XCTestCase

@end

@implementation AR3DCustomerDemoUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Game"] tap];
    
    XCUIElement *backButton = app.buttons[@"back"];
    [backButton tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [app.buttons[@"2DDemo"] tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIElement *element = [[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element;
    [element tap];
    [element tap];
    [element tap];
    [element tap];
    [backButton tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [app.buttons[@"3DDemo"] tap];
    [backButton tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;

    
}

@end
