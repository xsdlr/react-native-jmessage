# React Native JMessage

React Native Module for JMessage.

* [Build](#build)
* [Installation](#installation)
  * [RNPM](#rnpm)
  * [Manual](#manual)
    * [iOS Setup](#ios-setup)
    * [Android Setup](#android-setup)
* [Example](#example)

##Build
React-Native bridge static library for jmessage SDK which requires:

- [x] iOS SDK 3.0.0 build 132
- [x] Android SDK 2.0.0

##Installation
```shell
npm install --save react-native-jmessage@latest
```
###RNPM
```
 react-native link react-native-jmessage
```
###Manual
```shell
npm install --save react-native-jmessage@latest
```
####iOS Setup

* Open your app's Xcode project

* Find the `RCTJMessage.xcodeproj` file within the `node_modules/react-native-jmessage/ios` directory  and drag it into the `Libraries` node in Xcode

* Select the project node in Xcode and select the "Build Phases" tab of your project configuration.

* Drag `libRCTJMessage.a` from `Libraries/RCTJMessage.xcodeproj/Products` into the "Link Binary With Libraries" section of your project's "Build Phases" configuration.

* Click the plus sign underneath the "Link Binary With Libraries" list and add the `libz.tbd,libsqlite3.tbd,libresolv.tbd,UIKit.framework,Foundation.framework,
SystemConfiguration.framework,CoreFoundation.framework,CFNetwork.framework,
Security.framework,CoreTelephony.framework` library .

* Click the plus sign underneath the "Link Binary With Libraries" list and add the JMessage.framework which locate in `../node_modules/react-native-jmessage/ios/RCTJMessage` and the jcore-ios-1.1.0.a which locate in `../node_modules/react-native-jmessage/ios/RCTJMessage/JMessage.framework`. Then Under the "Build Settings" tab of your project configuration, find the "Framework Search Paths" section and edit the value. Add a new value, `$(SRCROOT)/../node_modules/react-native-jmessage/ios/RCTJMessage/**`.

* add following code to your AppDelegate.m 
```objectiv-c
...
#import <JMessageModule/RCTJMessageModule.h>
```
* add following code to didFinishLaunchingWithOptions method
```objectiv-c
[JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
	#ifdef DEBUG
	[RCTJMessageModule setupJMessage:launchOptions apsForProduction:false category:nil];
	#else
	[RCTJMessageModule setupJMessage:launchOptions apsForProduction:true category:nil];
	#endif
```
* add JiguangAppKey、JiguangMasterSecret and JiguangAppChannel into Info.plist

####Android Setup

* In your `android/settings.gradle` file, make the following additions:

    ```gradle
    include ':react-native-jmessage'
project(':react-native-jmessage').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-jmessage/android')
    ```

* In your `android/app/build.gradle` file, add the `:react-native-jmessage` project as a compile-time dependency:

    ```gradle
    ...
    dependencies {
        ...
        compile project(':react-native-jmessage')
    }
    ```
* add AppKey、AppChannel and MasterSecret to `android/build.gradle` which locate in react-native-jmessage node_modules folder

    ```gradle
    ...
  manifestPlaceholders = [
            JIGUANG_APPKEY: ${JIGUANG_APPKEY},
            JGUANG_APPCHANNEL: "developer-default",
            JIGUANG_MASTER_SECRET: ${JIGUANG_MASTER_SECRET}
        ]
    ```
* Update the `MainApplication.java` file to use react-native-jmessage via the following changes:

```java
...
import com.xsdlr.rnjmessage.JMessagePackage;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        ...

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                new MainReactPackage(),
                new JMessagePackage(BuildConfig.DEBUG)
            );
        }
    };
}
```
##Example
[react-native-jmessage-example](https://github.com/xsdlr/react-native-jmessage-example)


