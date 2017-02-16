# React Native JMessage

极光IM React Native 模块

支持iOS和android，支持RN@0.40+

[英文文档](https://github.com/xsdlr/react-native-jmessage/blob/master/README_EN.md)

* [构建](#构建)
* [安装](#安装)
  * [RNPM](#rnpm)
  * [手动](#手动)
    * [iOS](#ios)
    * [Android](#android)
* [示例](#示例)

##构建
本模块使用官方jmessage版本如下：

- [x] iOS SDK 3.0.0 build 132
- [x] Android SDK 2.0.0

##安装
```shell
npm install --save react-native-jmessage@latest
```
###RNPM
```
 react-native link react-native-jmessage
```
###手动
```shell
npm install --save react-native-jmessage@latest
```
####iOS

* 打开你的Xcode工程

* 在`node_modules/react-native-jmessage/ios`目录下找到`RCTJMessage.xcodeproj` 把它拖到`Libraries`中

* 选择项目中的"Build Phases"进行配置

* 在`Libraries/RCTJMessage.xcodeproj/Products`目录下找到`libRCTJMessage.a`拖到 "Link Binary With Libraries"中

* 在"Link Binary With Libraries"列表中添加以下库：
`libz.tbd,libsqlite3.tbd,libresolv.tbd,UIKit.framework,Foundation.framework,
SystemConfiguration.framework,CoreFoundation.framework,CFNetwork.framework,
Security.framework,CoreTelephony.framework`

* 在`../node_modules/react-native-jmessage/ios/RCTJMessage`目录下找到`JMessage.framework`，在`../node_modules/react-native-jmessage/ios/RCTJMessage/JMessage.framework`目录下找到`jcore-ios-1.1.0.a`，把这两个文件拖到"Link Binary With Libraries"中，在"Build Settings"标签设置的"Framework Search Paths"中添加`$(SRCROOT)/../node_modules/react-native-jmessage/ios/RCTJMessage/**`

* 在AppDelegate.m文件中添加以下代码 
```objectiv-c
...
#import <JMessageModule/RCTJMessageModule.h>
```

* 在didFinishLaunchingWithOptions方法中添加以下代码
```objectiv-c
[JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
	#ifdef DEBUG
	[RCTJMessageModule setupJMessage:launchOptions apsForProduction:false category:nil];
	#else
	[RCTJMessageModule setupJMessage:launchOptions apsForProduction:true category:nil];
	#endif
```

* 在Info.plist文件中添加JiguangAppKey、JiguangMasterSecret and JiguangAppChannel

####Android

* 在`android/settings.gradle`文件中添加如下代码

    ```gradle
    include ':react-native-jmessage'
project(':react-native-jmessage').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-jmessage/android')
    ```

* 在`android/app/build.gradle`文件中添加引用

    ```gradle
    ...
    dependencies {
        ...
        compile project(':react-native-jmessage')
    }
    ```
* 在 react-native-jmessage node_modules的`android/build.gradle`文件中添加 AppKey、AppChannel、MasterSecret

    ```gradle
    ...
  manifestPlaceholders = [
            JIGUANG_APPKEY: ${JIGUANG_APPKEY},
            JGUANG_APPCHANNEL: "developer-default",
            JIGUANG_MASTER_SECRET: ${JIGUANG_MASTER_SECRET}
        ]
    ```
* 在`MainApplication.java`文件中添加以下代码

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
##示例
[react-native-jmessage-example](https://github.com/xsdlr/react-native-jmessage-example)


