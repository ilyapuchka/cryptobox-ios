// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CBTestCase.h"

@import Cryptobox;


@interface CBLastPreKeyTest : CBTestCase

@end

@implementation CBLastPreKeyTest

- (void)testThatLastPrekeyTestCanRun
{
    CBCryptoBox *aliceBox = [self createBoxAndCheckAsserts:@"alice"];
    CBCryptoBox *bobBox = [self createBoxAndCheckAsserts:@"bob"];

    NSError *error = nil;
    CBPreKey *bobLastPreKey = [bobBox lastPreKey:&error];
    XCTAssertNotNil(bobLastPreKey);
    XCTAssertNil(error);
    
    CBSession *aliceSession = [aliceBox sessionWithId:@"alice" fromPreKey:bobLastPreKey error:&error];
    XCTAssertNotNil(aliceSession);
    XCTAssertNil(error);
    
    const NSString *plain = @"Hello Bob!";
    NSData *plainData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [aliceSession encrypt:plainData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(cipherData);
    
                               
    CBSession *bobSession = nil;
    CBSessionMessage *bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    XCTAssertNotNil(bobSessionMessage.session);
    XCTAssertNotNil(bobSessionMessage.data);

    bobSession = bobSessionMessage.session;
    NSString *decrypted = [[NSString alloc] initWithData:bobSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);
    
    [bobSession save:&error];
    XCTAssertNil(error);
    [bobBox closeSession:bobSession];
    bobSession = nil;
    decrypted = nil;
    
    // Bob's last prekey is not removed
    bobSessionMessage = [bobBox sessionMessageWithId:@"bob" fromMessage:cipherData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(bobSessionMessage);
    decrypted = [[NSString alloc] initWithData:bobSessionMessage.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([plain isEqualToString:decrypted]);
}

@end
