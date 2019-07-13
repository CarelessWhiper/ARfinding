//
//  CoreBlueTeachManager.h
//  location
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoreBluetoothManager : NSObject

+ (CLBeaconRegion *)defaultRegion;

- (void)startBeaconSingal:(CLBeaconRegion *)region;

- (void)stopBeaconSingal;

- (BOOL)isAdvertising;

@end
