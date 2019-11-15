//
//  UIDevice+Extension.m
//
//  Created by Muhammed Gurhan Yerlikaya on 15.11.2019.
//  Copyright © 2019. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <mach-o/arch.h>
#import "UIDevice+Extension.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000

@interface NSDictionary (subscripts)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary (subscripts)
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
@end

@interface NSArray (subscripts)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray (subscripts)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@implementation NSDictionary (subscripts)
- (id)objectForKeyedSubscript:(id)key;
{ return [self objectForKey:key]; }
@end

#endif

@implementation UIDevice (Extension)
/*
 Platforms
 
 iFPGA ->        ??
 
 iPhone1,1 ->    iPhone 1, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/GSM, N89
 iPhone3,2 ->    iPhone 4/GSM Rev A, N90
 iPhone3,3 ->    iPhone 4/CDMA, N92
 iPhone4,1 ->    iPhone 4S/GSM+CDMA, N94
 iPhone5,1 ->    iPhone 5/GSM, N41
 iPhone5,2 ->    iPhone 5/GSM+CDMA, N42
 iPhone5,3 ->    iPhone 5C/GSM, N48
 iPhone5,4 ->    iPhone 5C/GSM+CDMA, N49
 iPhone6,1 ->    iPhone 5S/GSM, N51
 iPhone6,2 ->    iPhone 5S/GSM+CDMA, N53
 iPhone7,2 ->    iPhone 6, N61
 iPhone7,1 ->    iPhone 6 Plus, N56
 iPhone8,1 ->    iPhone 6S/Samsung, N71
 iPhone8,1 ->    iPhone 6S/TSMC, N71m
 iPhone8,2 ->    iPhone 6S Plus/Samsung, N66
 iPhone8,2 ->    iPhone 6S Plus/TSMC, N66m
 iPhone8,4 ->    iPhone SE/TSMC, N69
 iPhone8,4 ->    iPhone SE/Samsung, N69u
 iPhone9,1 ->    iPhone 7/?, D10
 iPhone9,3 ->    iPhone 7/?, D101
 iPhone9,2 ->    iPhone 7 Plus/?, D11
 iPhone9,4 ->    iPhone 7 Plus/?, D111
 
 iPod1,1   ->    iPod touch 1, N45
 iPod2,1   ->    iPod touch 2, N72
 iPod2,2   ->    iPod touch 3, Prototype
 iPod3,1   ->    iPod touch 3, N18
 iPod4,1   ->    iPod touch 4, N81
 
 ipad0,1   ->    iPad, Prototype
 iPad1,1   ->    iPad 1, WiFi and 3G, K48
 iPad2,1   ->    iPad 2, WiFi, K93
 iPad2,2   ->    iPad 2, GSM 3G, K94
 iPad2,3   ->    iPad 2, CDMA 3G, K95
 iPad2,4   ->    iPad 2, WiFi R2, K93A
 iPad3,1   ->    The new iPad, WiFi
 iPad3,2   ->    The new iPad, CDMA
 iPad3,3   ->    The new iPad
 iPad4,1   ->    (iPad 4G, WiFi)
 iPad4,2   ->    (iPad 4G, GSM)
 iPad4,3   ->    (iPad 4G, CDMA)
 
 iProd2,1   ->   AppleTV 2, Prototype
 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??
 
 i386, x86_64 -> iPhone Simulator
 */


#pragma mark - Sysctlbyname Utils

- (NSString*)getSysInfoByName:(char*)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char* answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString* results = @(answer);
    
    free(answer);
    return results;
}

- (NSString*)platform {
    return [self getSysInfoByName:"hw.machine"];
}


- (NSString*)hwmodel {
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark - Sysctl Utils

- (NSUInteger)getSysInfo:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger)results;
}

- (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency {
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)cpuCount {
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemory {
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory {
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize {
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark - File system

- (NSNumber*)totalDiskSpace {
    NSDictionary* fattributes =
    [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemSize];
}

- (NSNumber*)freeDiskSpace {
    NSDictionary* fattributes =
    [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return fattributes[NSFileSystemFreeSize];
}

+ (NSInteger)getSubmodel:(NSString*)platform {
    NSInteger submodel = -1;
    
    NSArray* components = [platform componentsSeparatedByString:@","];
    if ([components count] >= 2) {
        submodel = [[components objectAtIndex:1] intValue];
    }
    return submodel;
}

#pragma mark - platform type and name utils

- (NSUInteger)platformType {
    return [UIDevice platformTypeForString:[self platform]];
}

- (NSString*)platformString {
    return [UIDevice platformStringForType:[self platformType]];
}

+ (BOOL)is86PlatformPrefix:(NSString*)platform {
    return [platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"];
}

+ (BOOL)isSmallerScreenForPlatform:(NSString*)platform {
    BOOL smallerScreen = YES;
    
    // Simulator
    if ([self is86PlatformPrefix:platform]) {
        smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
    }
    
    return smallerScreen;
}

+ (NSUInteger)platformTypeForString:(NSString*)platform {
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"]) return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return UIDeviceiPhone1;
    if ([platform isEqualToString:@"iPhone1,2"]) return UIDeviceiPhone3G;
    if ([platform hasPrefix:@"iPhone2"]) return UIDeviceiPhone3GS;
    if ([platform isEqualToString:@"iPhone3,1"]) return UIDeviceiPhone4GSM;
    if ([platform isEqualToString:@"iPhone3,2"]) return UIDeviceiPhone4GSMRevA;
    if ([platform isEqualToString:@"iPhone3,3"]) return UIDeviceiPhone4CDMA;
    if ([platform hasPrefix:@"iPhone4"]) return UIDeviceiPhone4S;
    if ([platform isEqualToString:@"iPhone5,1"]) return UIDeviceiPhone5GSM;
    if ([platform isEqualToString:@"iPhone5,2"]) return UIDeviceiPhone5CDMA;
    if ([platform isEqualToString:@"iPhone5,3"]) return UIDeviceiPhone5CGSM;
    if ([platform isEqualToString:@"iPhone5,4"]) return UIDeviceiPhone5CGSMCDMA;
    if ([platform isEqualToString:@"iPhone6,1"]) return UIDeviceiPhone5SGSM;
    if ([platform isEqualToString:@"iPhone6,2"]) return UIDeviceiPhone5SGSMCDMA;
    if ([platform isEqualToString:@"iPhone7,2"]) return UIDeviceiPhone6;
    if ([platform isEqualToString:@"iPhone7,1"]) return UIDeviceiPhone6Plus;
    if ([platform isEqualToString:@"iPhone8,1"]) return UIDeviceiPhone6S;
    if ([platform isEqualToString:@"iPhone8,2"]) return UIDeviceiPhone6SPlus;
    if ([platform isEqualToString:@"iPhone8,4"]) return UIDeviceiPhoneSE;
    if ([platform isEqualToString:@"iPhone9,1"]) return UIDeviceiPhone7;
    if ([platform isEqualToString:@"iPhone9,3"]) return UIDeviceiPhone7;
    if ([platform isEqualToString:@"iPhone9,2"]) return UIDeviceiPhone7Plus;
    if ([platform isEqualToString:@"iPhone9,4"]) return UIDeviceiPhone7Plus;
    if ([platform isEqualToString:@"iPhone10,1"]) return UIDeviceiPhone8;
    if ([platform isEqualToString:@"iPhone10,2"]) return UIDeviceiPhone8Plus;
    if ([platform isEqualToString:@"iPhone10,3"]) return UIDeviceiPhoneX;
    if ([platform isEqualToString:@"iPhone10,4"]) return UIDeviceiPhone8;      // Global
    if ([platform isEqualToString:@"iPhone10,5"]) return UIDeviceiPhone8Plus;  // Global
    if ([platform isEqualToString:@"iPhone10,6"]) return UIDeviceiPhoneX;      // Global
    if ([platform isEqualToString:@"iPhone11,2"])   return UIDeviceiPhoneXS;
    if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"])   return UIDeviceiPhoneXSMax;
    if ([platform isEqualToString:@"iPhone11,8"]) return UIDeviceiPhoneXR;
    if ([platform isEqualToString:@"iPhone12,1"]) return UIDeviceiPhone11;
    if ([platform isEqualToString:@"iPhone12,3"]) return UIDeviceiPhone11Pro;
    if ([platform isEqualToString:@"iPhone12,5"]) return UIDeviceiPhone11ProMax;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"]) return UIDeviceiPod1;
    if ([platform isEqualToString:@"iPod2,2"]) return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod2"]) return UIDeviceiPod2;
    if ([platform hasPrefix:@"iPod3"]) return UIDeviceiPod3;
    if ([platform hasPrefix:@"iPod4"]) return UIDeviceiPod4;
    if ([platform hasPrefix:@"iPod5"]) return UIDeviceiPod5;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"]) return UIDeviceiPad1;
    if ([platform hasPrefix:@"iPad2"]) {
        NSInteger submodel = [UIDevice getSubmodel:platform];
        if (submodel <= 4) {
            return UIDeviceiPad2;
        } else {
            return UIDeviceiPadMini;
        }
    }
    if ([platform hasPrefix:@"iPad3"]) {
        NSInteger submodel = [UIDevice getSubmodel:platform];
        if (submodel <= 3) {
            return UIDeviceTheNewiPad;
        } else {
            return UIDeviceiPad4G;
        }
    }
    
    if ([platform isEqualToString:@"iPad4,1"]) return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad4,2"]) return UIDeviceiPadAirLTE;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"]) return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"]) return UIDeviceAppleTV3;
    if ([platform hasPrefix:@"AppleTV4"]) return UIDeviceAppleTV4;
    if ([platform hasPrefix:@"AppleTV5"]) return UIDeviceAppleTV5;
    if ([platform hasPrefix:@"AppleTV6"]) return UIDeviceAppleTV6;
    
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceUnknownAppleTV;
    
    
    if ([self is86PlatformPrefix:platform]) {
        if ([self isSmallerScreenForPlatform:platform]) {
            return UIDeviceiPhoneSimulatoriPhone;
        } else {
            return UIDeviceiPhoneSimulatoriPad;
        }
    }
    
    return UIDeviceUnknown;
}

+ (NSString*)platformStringForType:(NSUInteger)platformType {
    switch (platformType) {
        case UIDeviceiPhone1:
            return IPHONE_1_NAMESTRING;
        case UIDeviceiPhone3G:
            return IPHONE_3G_NAMESTRING;
        case UIDeviceiPhone3GS:
            return IPHONE_3GS_NAMESTRING;
        case UIDeviceiPhone4GSM:
            return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4GSMRevA:
            return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4CDMA:
            return IPHONE_4_NAMESTRING;
        case UIDeviceiPhone4S:
            return IPHONE_4S_NAMESTRING;
        case UIDeviceiPhone5GSM:
            return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CDMA:
            return IPHONE_5_NAMESTRING;
        case UIDeviceiPhone5CGSM:
            return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5CGSMCDMA:
            return IPHONE_5C_NAMESTRING;
        case UIDeviceiPhone5SGSM:
            return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone5SGSMCDMA:
            return IPHONE_5S_NAMESTRING;
        case UIDeviceiPhone6:
            return IPHONE_6_NAMESTRING;
        case UIDeviceiPhone6Plus:
            return IPHONE_6_PLUS_NAMESTRING;
        case UIDeviceiPhone6S:
            return IPHONE_6S_NAMESTRING;
        case UIDeviceiPhone6SPlus:
            return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceiPhoneSE:
            return IPHONE_SE_NAMESTRING;
        case UIDeviceiPhone7:
            return IPHONE_7_NAMESTRING;
        case UIDeviceiPhone7Plus:
            return IPHONE_7_PLUS_NAMESTRING;
        case UIDeviceiPhone8:
            return IPHONE_8_NAMESTRING;
        case UIDeviceiPhone8Plus:
            return IPHONE_8_PLUS_NAMESTRING;
        case UIDeviceiPhoneX:
            return IPHONE_X_NAMESTRING;
        case UIDeviceiPhoneXS:
            return IPHONE_XS_NAMESTRING;
        case UIDeviceiPhoneXSMax:
            return IPHONE_XSMax_NAMESTRING;
        case UIDeviceiPhoneXR:
            return IPHONE_XR_NAMESTRING;
        case UIDeviceiPhone11:
            return IPHONE_11_NAMESTRING;
        case UIDeviceiPhone11Pro:
            return IPHONE_11Pro_NAMESTRING;
        case UIDeviceiPhone11ProMax:
            return IPHONE_11ProMax_NAMESTRING;
        case UIDeviceUnknowniPhone:
            return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPod1:
            return IPOD_1_NAMESTRING;
        case UIDeviceiPod2:
            return IPOD_2_NAMESTRING;
        case UIDeviceiPod3:
            return IPOD_3_NAMESTRING;
        case UIDeviceiPod4:
            return IPOD_4_NAMESTRING;
        case UIDeviceiPod5:
            return IPOD_5_NAMESTRING;
        case UIDeviceUnknowniPod:
            return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPad1:
            return IPAD_1_NAMESTRING;
        case UIDeviceiPad2:
            return IPAD_2_NAMESTRING;
        case UIDeviceTheNewiPad:
            return THE_NEW_IPAD_NAMESTRING;
        case UIDeviceiPad4G:
            return IPAD_4G_NAMESTRING;
        case UIDeviceiPadAir:
            return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadAirLTE:
            return IPAD_AIR_LTE_NAMESTRING;
        case UIDeviceiPadMini:
            return IPAD_MINI_NAMESTRING;
        case UIDeviceUnknowniPad:
            return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2:
            return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3:
            return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4:
            return APPLETV_4G_NAMESTRING;
        case UIDeviceAppleTV5:
            return APPLETV_5G_NAMESTRING;
        case UIDeviceAppleTV6:
            return APPLETV_5G_NAMESTRING;
        case UIDeviceUnknownAppleTV:
            return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiPhoneSimulator:
            return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone:
            return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad:
            return IPHONE_SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV:
            return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA:
            return IFPGA_NAMESTRING;
            
        default:
            return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (NSString*)platformStringForPlatform:(NSString*)platform {
    NSUInteger platformType = [UIDevice platformTypeForString:platform];
    return [UIDevice platformStringForType:platformType];
}

+ (BOOL)hasRetinaDisplay {
    return ([UIScreen mainScreen].scale == 2.0f);
}

+ (NSString*)imageSuffixRetinaDisplay {
    return @"@2x";
}

+ (BOOL)has4InchDisplay {
    return ([UIScreen mainScreen].bounds.size.height == 568);
}

+ (NSString*)imageSuffix4InchDisplay {
    return @"-568h";
}

- (UIDeviceFamily)deviceFamily {
    NSString* platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    if ([UIDevice is86PlatformPrefix:platform]) {
        if ([UIDevice isSmallerScreenForPlatform:platform]) {
            return UIDeviceFamilyiPhone;
        } else {
            return UIDeviceFamilyiPad;
        }
    }
    
    return UIDeviceFamilyUnknown;
}

+ (NSString*)osArchitecture {
    NXArchInfo* info = NXGetLocalArchInfo();
    NSString* typeOfCpu = [NSString stringWithUTF8String:info->description];
    return ![typeOfCpu isEqualToString:@""] ? typeOfCpu : @"Unknown";
}

#pragma mark - MAC addy

// Return the local MAC Address
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update.

- (NSString*)macaddress {
    int mib[6];
    size_t len;
    char* buf;
    unsigned char* ptr;
    struct if_msghdr* ifm;
    struct sockaddr_dl* sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr*)buf;
    sdl = (struct sockaddr_dl*)(ifm + 1);
    ptr = (unsigned char*)LLADDR(sdl);
    NSString* outstring =
    [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr + 1), *(ptr + 2),
     *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    // NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
    //                       *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}

// Illicit Bluetooth check -- cannot be used in App Store
/*
 Class  btclass = NSClassFromString(@"GKBluetoothSupport");
 if ([btclass respondsToSelector:@selector(bluetoothStatus)])
 {
 printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
 bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
 printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
 }
 */

+ (BOOL)isJailbroken {
    NSArray* paths = @[
                       @"/bin/bash",
                       @"/usr/sbin/sshd",
                       @"/etc/apt",
                       @"/private/var/lib/apt/",
                       @"/Applications/Cydia.app",
                       ];
    
    for (NSString* path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    
    // Try to write file in private
    NSError* error = nil;
    [@"Jailbreak test string" writeToFile:@"/private/test_jb.txt"
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
    if (error == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
        return YES;
    }
    
    return NO;
}

@end
