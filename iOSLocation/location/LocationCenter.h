//
//  LocationCenter.h
//  location
//


#import <Foundation/Foundation.h>
#import "LocationManager.h"

@interface LocationCenter : NSObject

@property (nonatomic,strong,readonly) LocationManager * locationManager;

+ (instancetype)defaultCenter;

@end
