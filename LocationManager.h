//
//  LocationManager.h
//  WarmHomeGZ
//
//  Created by huafangT on 2017/12/11.
//

#import <Foundation/Foundation.h>

typedef void(^LocationBlock)(NSString *longitude,NSString *latitude,NSString *address);

@interface LocationManager : NSObject

+ (LocationManager *)shareInstance;

//经纬度与详细地址
- (void)starLocation:(LocationBlock)locationBlock;

@end
