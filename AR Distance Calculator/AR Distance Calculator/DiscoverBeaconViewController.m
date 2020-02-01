
#import "ViewController.h"
#import "ARViewController.h"
#import "DiscoverBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocalPush.h"
#import "TestViewController.h"
#import "registerAppDelegate.h"
#import "FirstViewController.h"
#import "ARViewController.h"

#define Beacon_Device_UUID @"063FA845-F091-4129-937D-2A189A86D844"

@interface DiscoverBeaconViewController ()
<
CLLocationManagerDelegate
>


//检查定位权限 //
@property (nonatomic, strong) CLLocationManager *locationManager;
//需要被监听的beacon //
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property(nonatomic,strong) NSTimer *timer;
@end

@implementation DiscoverBeaconViewController
@synthesize database;
 -(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 在开始监控之前，我们需要判断改设备是否支持，和区域权限请求
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
                [self.locationManager startMonitoringForRegion:self.beaconRegion];
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
    
    [self.view addSubview:self.tableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        // 监听所有UUID为Beacon_Device_UUID的Beacon设备
       _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] identifier:@"test"];
        
         //监听UUID为Beacon_Device_UUID，major为666的所有Beacon设备
        //_beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] major:11 identifier:@"test"];
        
        // 监听UUID为Beacon_Device_UUID，major为666，minor为999的唯一一个Beacon设备
        //        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] major:666 minor:999 identifier:@"test"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
    }
    return _beaconRegion;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataDict[_dataDict.allKeys[section]] count];
}

   
   

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
   
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(self.class)];
    }
    
    NSString *key = _dataDict.allKeys[indexPath.section];
 CLBeacon *beacon = [_dataDict valueForKey:key][indexPath.row];
   //cell.textLabel.text = [NSString stringWithFormat:@"%@",[result stringForColumn:@"pwd"]];
    NSLog(@"home=%@",NSHomeDirectory());
    //将数据库文件加载到沙盒decument目录中
    NSArray* array=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath=[[array objectAtIndex:0] stringByAppendingPathComponent:@"user.db"];
    NSLog(@"%@",filePath);
    NSFileManager* fm=[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath])
    {
        NSLog(@"目录未找到");
        NSString* path=[[NSBundle mainBundle] pathForResource:@"user" ofType:@"db"];
        if ([fm copyItemAtPath:path toPath:filePath error:nil]) {
            NSLog(@"copy file suceess");
        }else
        {
            NSLog(@"Fail to copy ");
        }
    }

    self.database=[[FMDatabase alloc]initWithPath:filePath];
 if ([database open]) {
         [database beginTransaction];
         FMResultSet* result = [database executeQueryWithFormat:@"select * from users where userName = %@", beacon.major];
       while ([result next]) {
           //cell.textLabel.text = [NSString stringWithFormat:@"Major:%@    Minor:%@",beacon.major,beacon.minor];
           cell.detailTextLabel.text = [NSString stringWithFormat:@"distance:%.1f",3.5*beacon.accuracy];
           cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0f];
           NSLog(@"the result name = %@ password = %@",[result stringForColumn:@"userName"],[result stringForColumn:@"pwd"]);
cell.textLabel.text = [NSString stringWithFormat:@"%@",[result stringForColumn:@"pwd"]];
       }
  }
   [database commit];//提交事务

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *key = _dataDict.allKeys[indexPath.section];
    CLBeacon *beacon = [_dataDict valueForKey:key][indexPath.row];
      ARViewController *vc = [[ARViewController alloc] init];
        vc.title = cell.textLabel.text;
    vc.firstValue = [NSString stringWithFormat:@"%@",beacon.major];
        [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = _dataDict.allKeys[section];
    NSArray *arr = [_dataDict valueForKey:key];
    return [NSString stringWithFormat:@"(%ld)%@-...-%@",(unsigned long)arr.count,[key substringToIndex:8],[key substringFromIndex:24]];
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status  {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

#pragma mark -- Monitoring

//进入区域 //
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region  {
    
}

//离开区域 //
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region  {
    
}

// Monitoring有错误产生时的回调 //
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error {
    
}

/** Monitoring 成功回调 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}


#pragma mark -- Ranging

// 1秒钟执行1次 //
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    
    for (CLBeacon *beacon in beacons  ) {
        NSLog(@" rssi is :%ld",(long)beacon.rssi);
        NSLog(@" beacon proximity :%ld",(long)beacon.proximity);
        NSLog(@" accuracy :%f",beacon.accuracy);
        NSLog(@" proximityUUID : %@",beacon.proximityUUID.UUIDString);
        NSLog(@" major :%ld",(long)beacon.major.integerValue);
        NSLog(@" minor :%ld",(long)beacon.minor.integerValue);
        
    }
    
    if (!_dataDict) {
        _dataDict = [NSMutableDictionary dictionary];
    }
    if (beacons.count) {
        [_dataDict setObject:beacons forKey:region.proximityUUID.UUIDString];
        
    } else {
        [_dataDict removeObjectForKey:region.proximityUUID.UUIDString];
    }
    
    
    [self.tableView reloadData];
    
    
}

/** ranging有错误产生时的回调  */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error  {
    
}

#pragma mark -- Kill callBack

//杀掉进程之后的回调，直接锁屏解锁，会触发 //
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    {
        
        LocalPush *localNotification = [[LocalPush alloc] init];
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"你监听的Beacon区域状态：%@,锁屏点亮屏幕会收到此推送",nil),(state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"];
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *bregion = (CLBeaconRegion *)region;
            NSString *body = [NSString stringWithFormat:@"status = %@,uuid = %@,major=%ld,minor=%ld",((state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"),bregion.proximityUUID.UUIDString,[bregion.major integerValue],[bregion.minor integerValue]];
            localNotification.body = body;
            localNotification.soundName = nil;
            localNotification.delayTimeInterval = 0.0;
            [localNotification pushLocalNotification];
        }
    }
}
-(void)readUser
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* nameStr = [defaults objectForKey:@"NAME"];
    NSString* pwdStr = [defaults objectForKey:@"PASSWORD"];
    if(nameStr&& pwdStr)
    {
        self.textUser.text = nameStr;
        self.textPassword.text = pwdStr;
    }
}
@end




