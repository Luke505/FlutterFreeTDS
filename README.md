# FreeTDS for Flutter

FreeTDS for Flutter is a Flutter library that enables connectivity to a SAP Sql Anywhere 17 database.

## Installation

### Using Docker

If you want to use Docker to create a development environment, follow these steps:

1. Make sure Docker is installed on your system.
2. Navigate to the "db" folder in your project.
3. Copy the file "sqlany17.tar" to the "installer" folder, You can download a trial version from [this link](https://www.sap.com/products/technology-platform/sql-anywhere/trial.html).
4. Run the `docker build . --tag=sybase:17 --network=host` command to create a Docker image with SAP Sql Anywhere 17.
5. Run the `docker-compose up -d` command to start a Docker container with SAP Sql Anywhere 17.
6. Once the container is up and running, you can use the SAP Sql Anywhere 17 database for developing and testing your library.

### Manual Installation

If you prefer to install SAP Sql Anywhere 17 manually, follow these steps:

1. Download SAP Sql Anywhere 17 from the [download page](https://www.sap.com/products/technology-platform/sql-anywhere/trial.html).
2. Extract the contents of the "sqlany17.tar" file to your system.
3. Follow the installation instructions for SAP Sql Anywhere 17 provided in the official documentation.

## Using the Library

Now that you've set up your SAP Sql Anywhere 17 environment, you can use FreeTDS for Flutter to connect to the database.

## FreeTDS Native Library

FreeTDS for Flutter utilizes the native FreeTDS library version 1.4.22. Modifications and enhancements have been made to this version. You can review the specific changes in
the [changelog here](https://github.com/Luke505/AppleFreeTDS/blob/main/src/freetds/ChangeLog.md).

### Build Instructions

#### MacOS
1. Build the project using Xcode for:
    - Mac (Mac Catalyst, arm64, x86_64)

#### iOS
1. Build the project using Xcode for:
	- Any iOS Device (arm64)
	- Any iOS Simulator Device (arm64, x86_64)
2. Merge the builds into a single XCFramework with the following command:
   ```bash
   xcodebuild -create-xcframework \
   -framework ./Release-iphoneos/FreeTDS-iOS.framework \
   -framework ./Release-iphonesimulator/FreeTDS-iOS.framework \
   -output xcframeworks/FreeTDS-iOS.xcframework
   ```

#### Windows
1. Install the following dependencies:
	- [Strawberry Perl](https://strawberryperl.com)
	- [Cygwin](https://www.cygwin.com)
	- [Gperf](https://gnuwin32.sourceforge.net/packages/gperf.htm)
2. Build the project using [CMake](https://cmake.org/download/)

## License

FreeTDS for Flutter is released under the following license: [GNU LGPL](LICENSE).
