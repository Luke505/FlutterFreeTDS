//
//  FreeTDSKit.h
//  FreeTDSKit
//
//  Created by Luca Ciampa on 2023-09-26.
//
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#endif
#if !TARGET_OS_IPHONE && TARGET_OS_MAC
@import AppKit;
#endif

//! Project version number for FreeTDSKit.
FOUNDATION_EXPORT double FreeTDSKitVersionNumber;

//! Project version string for FreeTDSKit.
FOUNDATION_EXPORT const unsigned char FreeTDSKitVersionString[];

#import "sybdb.h"
