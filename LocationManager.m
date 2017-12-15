//
//  LocationManager.m
//  WarmHomeGZ
//
//  Created by huafangT on 2017/12/11.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy)LocationBlock locationBlock;
@property (nonatomic, copy)NSString * longitute;
@property (nonatomic, copy)NSString * latitude;
@property (nonatomic, copy)NSString * address;
@end

@implementation LocationManager

+ (LocationManager *)shareInstance{
    static LocationManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)starLocation:(LocationBlock)locationBlock{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        //定位不能用
        UIAlertView * aler = [[UIAlertView alloc]initWithTitle:@"定位不可用" message:@"请前往设置打开该应用的定位权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [aler show];
        return;
    }
    
    self.locationBlock = locationBlock;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = 100;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    /** 需要进行手动授权
     * 获取授权认证，两个方法：
     * [self.locationManager requestWhenInUseAuthorization];
     * [self.locationManager requestAlwaysAuthorization];
     */
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        NSLog(@"requestWhenInUseAuthorization");
        [self.locationManager requestWhenInUseAuthorization];//使用中授权
        //[self.locationManager requestAlwaysAuthorization];
    }
    
    //开始定位，不断调用其代理方法
    [self.locationManager startUpdatingLocation];
    NSLog(@"start gps");
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    self.longitute = [NSString stringWithFormat:@"%f",coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f",coordinate.latitude];
    
    //反向地理编码
    
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    
    CLLocation *cl = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    [clGeoCoder reverseGeocodeLocation:cl completionHandler: ^(NSArray *placemarks,NSError *error) {
        
        for (CLPlacemark *placeMark in placemarks) {
            
            NSDictionary *addressDic = placeMark.addressDictionary;
            
            NSString *state=[addressDic objectForKey:@"State"];
            
            NSString *city=[addressDic objectForKey:@"City"];
            
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
            
            NSString *street=[addressDic objectForKey:@"Street"];
            
            self.address = [NSString stringWithFormat:@"%@%@%@%@",state, city, subLocality, street];
            NSLog(@"所在城市====%@ %@ %@ %@", state, city, subLocality, street);
         
            if(self.locationBlock){
                self.locationBlock(self.longitute, self.latitude, self.address);
            }
        }
    }];
    
    // 2.停止定位
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
     //没有权限
        [aler show];
    }else if (error.code == kCLErrorNetwork){
      //网络错误
    }
}

@end
