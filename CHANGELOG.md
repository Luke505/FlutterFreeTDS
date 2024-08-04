# 2.0.0 (August 4, 2024)

* Updated the library version to v1.4.22
* Rebuilt macOS for x86_64 and arm64
* Rebuilt iOS for arm64 on real devices and for x86_64 and arm64 on simulators
* Rebuilt Windows
* FreeTDS is now a fully static class
* Replaced `FreeTDS.lastError` with the library's `dbgetlasterror` method
* Added `setMessageHandler` to set a custom message handler function
* Added `setErrorHandler` to set a custom error handler function
* Removed the default message handler and error handler functions

# 1.3.0 (July 18, 2024)

* SYBLONGCHAR data type now supported
* Added `appName` connection parameter

# 1.2.0 (June 27, 2024)

* Rebuild FreeTDS-macos for x86_64, i386 & arm64, and FreeTDS-ios for armv7, arm64 & armv7s  

## 1.1.1 (April 6, 2024)

* Fixed issues with multiple frameworks sharing the same name, ensuring better clarity and maintainability.

## 1.1.0 (February 18, 2024)

* Fixed issues with SYBNUMERIC & SYBREAL
* Added test for SYBUUID

## 1.0.0 (January 25, 2024)

* FreeTDS 1.4.10 flutter plugin for macOS, iOS and windows
