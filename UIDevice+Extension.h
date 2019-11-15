//
//  UIDevice+Extension.h
//
//  Created by Muhammed Gurhan Yerlikaya on 15.11.2019.
//  Copyright © 2019. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING @"iFPGA"

#define IPHONE_1_NAMESTRING @"iPhone 1"
#define IPHONE_3G_NAMESTRING @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING @"iPhone 3GS"
#define IPHONE_4_NAMESTRING @"iPhone 4"
#define IPHONE_4S_NAMESTRING @"iPhone 4S"
#define IPHONE_5_NAMESTRING @"iPhone 5"
#define IPHONE_5C_NAMESTRING @"iPhone 5C"
#define IPHONE_5S_NAMESTRING @"iPhone 5S"
#define IPHONE_6_NAMESTRING @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING @"iPhone 6 Plus"
#define IPHONE_6S_NAMESTRING @"iPhone 6S"
#define IPHONE_6S_PLUS_NAMESTRING @"iPhone 6S Plus"
#define IPHONE_SE_NAMESTRING @"iPhone SE"
#define IPHONE_7_NAMESTRING @"iPhone 7"
#define IPHONE_7_PLUS_NAMESTRING @"iPhone 7 Plus"
#define IPHONE_8_NAMESTRING @"iPhone 8"
#define IPHONE_8_PLUS_NAMESTRING @"iPhone 8 Plus"
#define IPHONE_X_NAMESTRING @"iPhone X"
#define IPHONE_XS_NAMESTRING @"iPhone XS"
#define IPHONE_XSMax_NAMESTRING @"iPhone XSMax"
#define IPHONE_XR_NAMESTRING @"iPhone XR"
#define IPHONE_11_NAMESTRING @"iPhone 11"
#define IPHONE_11Pro_NAMESTRING  @"iPhone 11Pro"
#define IPHONE_11ProMax_NAMESTRING @"iPhone 11ProMax"

#define IPHONE_UNKNOWN_NAMESTRING @"Unknown iPhone"

#define IPOD_1_NAMESTRING @"iPod touch 1"
#define IPOD_2_NAMESTRING @"iPod touch 2"
#define IPOD_3_NAMESTRING @"iPod touch 3"
#define IPOD_4_NAMESTRING @"iPod touch 4"
#define IPOD_5_NAMESTRING @"iPod touch 5"
#define IPOD_UNKNOWN_NAMESTRING @"Unknown iPod"

#define IPAD_1_NAMESTRING @"iPad 1"
#define IPAD_2_NAMESTRING @"iPad 2"
#define THE_NEW_IPAD_NAMESTRING @"The new iPad"
#define IPAD_4G_NAMESTRING @"iPad 4G"
#define IPAD_AIR_NAMESTRING @"iPad Air (WiFi)"
#define IPAD_AIR_LTE_NAMESTRING @"iPad Air (LTE)"

#define IPAD_MINI_NAMESTRING @"iPad mini"
#define IPAD_UNKNOWN_NAMESTRING @"Unknown iPad"

#define APPLETV_2G_NAMESTRING @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING @"Apple TV 4G"
#define APPLETV_5G_NAMESTRING @"Apple TV 5G"
#define APPLETV_6G_NAMESTRING @"Apple TV 6G (4K)"
#define APPLETV_UNKNOWN_NAMESTRING @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING @"Apple TV Simulator"

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone,  // both regular and iPhone 4 devices
    UIDeviceiPhoneSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDeviceiPhone1,
    UIDeviceiPhone3G,
    UIDeviceiPhone3GS,
    UIDeviceiPhone4,
    UIDeviceiPhone4GSM,
    UIDeviceiPhone4GSMRevA,
    UIDeviceiPhone4CDMA,
    UIDeviceiPhone4S,
    UIDeviceiPhone5,
    UIDeviceiPhone5GSM,
    UIDeviceiPhone5CDMA,
    UIDeviceiPhone5CGSM,
    UIDeviceiPhone5CGSMCDMA,
    UIDeviceiPhone5SGSM,
    UIDeviceiPhone5SGSMCDMA,
    UIDeviceiPhone6,
    UIDeviceiPhone6Plus,
    UIDeviceiPhone6S,
    UIDeviceiPhone6SPlus,
    UIDeviceiPhoneSE,
    UIDeviceiPhone7,
    UIDeviceiPhone7Plus,
    UIDeviceiPhone8,
    UIDeviceiPhone8Plus,
    UIDeviceiPhoneX,
    UIDeviceiPhoneXS,
    UIDeviceiPhoneXSMax,
    UIDeviceiPhoneXR,
    UIDeviceiPhone11,
    UIDeviceiPhone11Pro,
    UIDeviceiPhone11ProMax,
    
    UIDeviceiPod1,
    UIDeviceiPod2,
    UIDeviceiPod3,
    UIDeviceiPod4,
    UIDeviceiPod5,
    
    UIDeviceiPad1,
    UIDeviceiPad2,
    UIDeviceTheNewiPad,
    UIDeviceiPad4G,
    UIDeviceiPadAir,
    UIDeviceiPadAirLTE,
    UIDeviceiPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    UIDeviceAppleTV5,
    UIDeviceAppleTV6,
        
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,
    
} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
} UIDeviceFamily;

@interface UIDevice (Extension)
- (NSString*)platform;
- (NSString*)hwmodel;
- (NSUInteger)platformType;
- (NSString*)platformString;

- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)cpuCount;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (NSNumber*)totalDiskSpace;
- (NSNumber*)freeDiskSpace;

- (NSString*)macaddress;

+ (NSUInteger)platformTypeForString:(NSString*)platform;
+ (NSString*)platformStringForType:(NSUInteger)platformType;
+ (NSString*)platformStringForPlatform:(NSString*)platform;

+ (BOOL)hasRetinaDisplay;
+ (NSString*)imageSuffixRetinaDisplay;
+ (BOOL)has4InchDisplay;
+ (NSString*)imageSuffix4InchDisplay;

- (UIDeviceFamily)deviceFamily;
+ (NSString*)osArchitecture;

+ (BOOL)isJailbroken;

@end
