// This Source Code Form is subject to the terms of
// the Mozilla Public License, v. 2.0. If a copy of
// the MPL was not distributed with this file, You
// can obtain one at http://mozilla.org/MPL/2.0/.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CBTestCase.h"

@import Cryptobox;

@interface CBCryptoBoxTests : CBTestCase

@property (nonatomic) CBCryptoBox *box;

@end

@implementation CBCryptoBoxTests

- (void)setUp
{
    [super setUp];
    
    NSURL *directory = CBCreateTemporaryDirectoryAndReturnURL(self.name);
    self.box = [CBCryptoBox cryptoBoxWithPathURL:directory error:nil];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testThatPreKeysAreGettingGenerated
{
    NSRange range = (NSRange){0, 10};
    NSError *error = nil;
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(preKeys);
    XCTAssertEqual(preKeys.count, range.length);
}

- (void)testThatPreKeysGenerationErrorHandlingRespectsMaxLength
{
    NSRange range = (NSRange){0, CBMaxPreKeyID + 1};
    NSError *error = nil;
    
    XCTAssertThrowsSpecificNamed([self.box generatePreKeys:range error:&error], NSException, NSInvalidArgumentException, @"Should throw an invalid argument exception");
}

- (void)testThatPreKeysGenerationErrorHandlingChecksLocation
{
    // Should pass
    NSRange range = (NSRange){CBMaxPreKeyID, 1};
    NSError *error = nil;
    NSArray *preKeys = [self.box generatePreKeys:range error:&error];
#pragma unused(preKeys)
    XCTAssertNil(error);
    XCTAssertNotNil(preKeys);
    
    // Shouldn't pass
    range = (NSRange){CBMaxPreKeyID + 1, 1};
    XCTAssertThrowsSpecificNamed([self.box generatePreKeys:range error:&error], NSException, NSInvalidArgumentException, @"Should throw an invalid argument exception");
}

- (void)testThatPreKeysGenerationErrorHandlingChecksLength
{
    // Invalid input, no keys to generate
    NSRange range = (NSRange){0, 0};
    NSError *error = nil;
    
    XCTAssertThrowsSpecificNamed([self.box generatePreKeys:range error:&error], NSException, NSInvalidArgumentException, @"Should throw an invalid argument exception");
    
    // Out of max bounds
    range = (NSRange){0, CBMaxPreKeyID + 1};
    XCTAssertThrowsSpecificNamed([self.box generatePreKeys:range error:&error], NSException, NSInvalidArgumentException, @"Should throw an invalid argument exception");
}

- (void)testThatLastPreKeyReturnsPreKey
{
    NSError *error = nil;
    CBPreKey *preKey = [self.box lastPreKey:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(preKey);
}

- (void)testThatItCreatesSessionFromPreKey
{
    CBCryptoBox *aliceBox = [self createBoxAndCheckAsserts:@"alice"];
    CBCryptoBox *bobBox = [self createBoxAndCheckAsserts:@"bob"];
    
    CBPreKey *bobPreKey = [self generatePreKeyAndCheckAssertsWithLocation:1 box:bobBox];
    
    //Alice side
    NSError *error = nil;
    CBSession *aliceToBobSession = [aliceBox sessionWithId:@"sessionWithBob" fromPreKey:bobPreKey error:&error];
    XCTAssertNil(error, @"Error is not nil");
    XCTAssertNotNil(aliceToBobSession, @"Session creation from prekey failed");
}

- (void)testThatItCreatesSessionFromStringPreKey
{
    CBCryptoBox *aliceBox = [self createBoxAndCheckAsserts:@"alice"];
    CBCryptoBox *bobBox = [self createBoxAndCheckAsserts:@"bob"];
    
    CBPreKey *bobPreKey = [self generatePreKeyAndCheckAssertsWithLocation:1 box:bobBox];
    NSString *bobBase64StringKey = [bobPreKey.data base64EncodedStringWithOptions:0];
    
    //Alice side
    NSError *error = nil;
    CBSession *aliceToBobSession = [aliceBox sessionWithId:@"sessionWithBob" fromStringPreKey:bobBase64StringKey error:&error];
    XCTAssertNil(error, @"Error is not nil");
    XCTAssertNotNil(aliceToBobSession, @"Session creation from prekey failed");
}

@end
