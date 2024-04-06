//
//  FreeTDS.h
//  FreeTDS
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

//! Project version number for FreeTDS.
FOUNDATION_EXPORT double FreeTDSVersionNumber;

//! Project version string for FreeTDS.
FOUNDATION_EXPORT const unsigned char FreeTDSVersionString[];

#import "sybdb.h"
