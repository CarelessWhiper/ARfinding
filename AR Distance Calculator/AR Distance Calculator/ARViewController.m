#import "ARViewController.h"
#import "ViewController.h"
#import "DiscoverBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocalPush.h"
#import <SceneKit/SceneKit.h>
#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

#define Beacon_Device_UUID @"063FA845-F091-4129-937D-2A189A86D844"
@interface ARViewController () <ARSCNViewDelegate,ARSessionDelegate,SCNSceneRendererDelegate>{
  float y;
  float x;
    matrix_float4x4 _transform;
    NSInteger cubeNumber;
    UILabel *distanceLab;
    UILabel *totalDistanceLab;
    NSTimer *timer;
    CGFloat distance;
    UITapGestureRecognizer *tapGesture;
    NSInteger touchCount;
    CGFloat distanceTemp;
    CGFloat distanceA;
    CGFloat distanceB;
    CGFloat distanceC;
    CGFloat distanceD;
    
}

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) ARWorldTrackingConfiguration *arConfiguration;
@property (nonatomic, strong) UILabel *remindView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) ARHitTestResult *hitResult;
@property (nonatomic, strong) SCNNode *zeroNode;
@property (nonatomic, assign) BOOL *zeroNodeGeted;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) SCNNode *calculateNode;
@property (nonatomic, strong) SCNScene *scene;


@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) NSUInteger tapCount;


@property (nonatomic) ARTrackingState currentTrackingState;
@property (nonatomic, strong) NSString *currentMessage;
@property (nonatomic, strong) NSString *nextMessage;
//检查定位权限 //
@property (nonatomic, strong) CLLocationManager *locationManager;
//需要被监听的beacon //
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) UITableView *tableView;

//@property (weak, nonatomic) IBOutlet ARSCNView *arscnView;
/**箭头节点*/
@property(nonatomic, strong) SCNNode *arrow;
/**目标节点*/
@property(nonatomic, strong) SCNNode *target;
/**根节点*/
@property(nonatomic, strong, readonly) SCNNode *rootNode;
@end




@implementation ARViewController

- (void)queueMessage: (NSString *)message {
    // If we are currently showing a message, queue the next message. We will show
    // it once the previous message has disappeared. If multiple messages come in
    // we only care about showing the last one
    if (self.currentMessage) {
        self.nextMessage = message;
        return;
    }
    
    self.nextMessage = message;
    [self showNextMessage];
}

- (void)showNextMessage {
    self.currentMessage = self.nextMessage;
    self.nextMessage = nil;
    
    if (!_remindView) {
        _remindView = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, self.view.frame.size.width-20, 50)];
        _remindView.backgroundColor = [UIColor clearColor];
        _remindView.textAlignment = NSTextAlignmentCenter;
        //    _remindView.alpha = 0;
        //    _remindView.text = @"加载中。。。";
        [self.view addSubview:_remindView];
        [self.view bringSubviewToFront:_remindView];
        _remindView.alpha = 0.3;
    }
    
    if (self.currentMessage == nil) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _remindView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
        return;
    }
    
    _remindView.text = self.currentMessage;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _remindView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // Wait 5 seconds
        timer = [NSTimer scheduledTimerWithTimeInterval:4 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self showNextMessage];
        }];
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    cubeNumber = 0;
    self.sceneView = [[ARSCNView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.sceneView];
    // Set the view's delegate
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    //    self.sceneView.showsStatistics = YES;
    //    self.sceneView.allowsCameraControl = YES;
    //    Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    self.sceneView.rendersContinuously = YES;
    
    
    
    distanceLab = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 90, 200, 40)];
    [self.view addSubview:distanceLab];
   [self.view bringSubviewToFront:distanceLab];
    distanceLab.backgroundColor = [UIColor colorWithRed:96 green:96 blue:96 alpha:0.4];
    distanceLab.textAlignment = NSTextAlignmentCenter;
    //    distanceLab.alpha = 0.3;
    
      [self locationManager];
    

    //轻拍手势
      //UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
      //轻拍次数
     // tap.numberOfTapsRequired=2;
      //轻拍手指数
    //  tap.numberOfTouchesRequired=2;
     // [self.view addGestureRecognizer:tap];

  /*  self.sceneView.delegate = self;
     self.sceneView.showsStatistics = YES;
       /// 自动点亮默认光源场景
       self.sceneView.autoenablesDefaultLighting = true;
       /// 箭头添加子节点
       [self.arrow addChildNode:[self loadNodeWithName:@"arrow"]];
       /// 目标节点添加子节点
       [self.target addChildNode:[self loadNodeWithName:@"pointer"]];
       /// ARSceneView添加目标节点
       [self.rootNode addChildNode:self.target];
       /// 更新目标位置
       [self updateTargetPosition];
       /// 添加箭头节点, 更新箭头位置
       [self addArrow];*/
}

- (void)addArrow {
    /// 设置位置
    SCNVector3 position = self.arrow.position;
    position.z = -0.5;
    position.y = 0;
    self.arrow.position = position;
    
    SCNNode *node = [self.sceneView pointOfView];
    if (node) {
        [node addChildNode:self.arrow];
    }
}

/// 更新目标位置
- (void)updateTargetPosition {
    /// 设置位置
    SCNVector3 position = self.target.position;
    position.x =y;
    position.y =0;
     position.z =x;
    self.target.position = position;
}

/// 加载节点
/// @param name 名称
- (SCNNode *)loadNodeWithName: (NSString *)name {
    /// 本地资源地址
    NSURL *sceneURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"scn" subdirectory:@"game.scnassets"];
    /// 引用节点
    SCNReferenceNode *node = [[SCNReferenceNode alloc] initWithURL:sceneURL];
    [node load];
    node.name = name;
    return node;
}



/// ARSCNViewDelegate
/// @param renderer 引用
/// @param time 时间
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    
    SCNNode *node = [self.sceneView pointOfView];
    
    if (!node) {
        return;
    }
    
     NSArray<SCNNode *> *result = [self.sceneView nodesInsideFrustumWithPointOfView:node];
    
    if (!result || result.count == 0) {
        return;
    }
    
    if ([result containsObject:self.target]) {
        self.arrow.hidden = true;
    } else {
        self.arrow.hidden = false;
        // 改变箭头节点的方向，使其局部前向矢量指向目标位置
        [self.arrow lookAt:self.target.position];
    }
    [self.target lookAt:node.position];
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

#pragma - mark Getter

- (SCNNode *)rootNode {
    return self.sceneView.scene.rootNode;
}

- (SCNNode *)arrow {
    if (!_arrow) {
        _arrow = ({
            SCNNode *object = [[SCNNode alloc] init];
            object;
        });
    }
    return _arrow;
}

- (SCNNode *)target {
    if (!_target) {
        _target = ({
            SCNNode *object = [[SCNNode alloc] init];
            object;
        });
    }
    return _target;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //     创建世界追踪配置会话配置，需要A9芯片支持
    //    [self showRemind:@"正在加载"];
    _arConfiguration = [ARWorldTrackingConfiguration new];
    //    设置追踪方向（
    _arConfiguration.planeDetection = ARPlaneDetectionHorizontal;
    _arConfiguration.lightEstimationEnabled = YES;
    // Run the view's session
    [self.sceneView.session runWithConfiguration:_arConfiguration];
    
    //    [self hiddenRemind:@"加载完成"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
    
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMessage:(NSString *)message {
    [self queueMessage:message];
}

#pragma mark - handleTap






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    [self showMessage:@"session error"];
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
    int i = [_firstValue intValue];
    if (!_beaconRegion) {
        // 监听所有UUID为Beacon_Device_UUID的Beacon设备
        //_beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] identifier:@"test"];
        
        // 监听UUID为Beacon_Device_UUID，major为666的所有Beacon设备
                _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:Beacon_Device_UUID] major:i identifier:@"test"];
        
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"Major:%@    Minor:%@",beacon.major,beacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"rssi:%ld   accuracy:%.1fm",(long)beacon.rssi,beacon.accuracy?:-1];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0f];
    
    return cell;
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
        NSLog(@" accuracy : %f",beacon.accuracy);
        NSLog(@" proximityUUID : %@",beacon.proximityUUID.UUIDString);
        NSLog(@" major :%ld",(long)beacon.major.integerValue);
        NSLog(@" minor :%ld",(long)beacon.minor.integerValue);
        distanceTemp = (int)(beacon.accuracy*35)*0.1;
       // if(touchCount>=4){
      // distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",beacon.accuracy];
       // }
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
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    float a=0.0;
    float b=0.0;
    CGFloat tempDistance = distanceTemp;
    //distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",distanceTemp];
    
    //用于记录第几次
    touchCount++;
    if (touchCount == 1) {  //第一次
        distanceA = tempDistance;
        //distanceA=0.4;
        distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",distanceA];

    }
    else if(touchCount == 2)
    {//第二次
       distanceB = tempDistance;
        //distanceB = 0.5;
         distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",distanceB];
    }
    else if(touchCount == 3)
    {  //第三次
        distanceC = tempDistance;
         distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",distanceC];
    }
    else if(touchCount == 4)
    {  // 第四次
      distanceD = tempDistance;
        //distanceD= 1;
        // distanceLab.text = [NSString stringWithFormat:@"x:%.1f y:%.1f",x,y];
          distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",distanceD];
     if(distanceB<distanceD)//分两种情况
      {
       a=(distanceD)/((distanceD*distanceD)+1-(distanceB*distanceB));//公式1 L0设为0.5米

//distanceLab.text = [NSString stringWithFormat:@" accuracy : %f",a];
      
           if(a<0)
           {
                a=-1*a;
            }
        x=((0.5*(distanceD-a))/a)+0.5;//公式2
        b=sqrt(a*a-0.25);//公式3
            y=(b*distanceD/a)+1;//公式4
            if(x<0)
            {x=-1*x;}
            if(y<0)
            {y=-1*y;}
            if(((distanceA<distanceD)&&(distanceB<distanceD)))//判断象限
           {
                x=-1*x;
                y=-1*y;
           }
          if(((distanceC<distanceA)&&(distanceB<distanceD)))//判断象限
                 {
                     x=-1*x;
               
            }
          //distanceLab.text = [NSString stringWithFormat:@" accuracy: %f",distanceD];
      }
        
 if(distanceB>distanceD)
    {
        a=(distanceB)/((distanceB*distanceB)+1-(distanceD*distanceD));
        x=(0.25*(distanceB-a))/a;
        b=sqrt(a*a-0.25);
            y=b*distanceB/a;
          
                      if(((distanceC>distanceA)&&(distanceD<distanceB)))
                           {
                               y=-1*y;
                         
                      }
            
        }
        if((distanceB==distanceD)&&(distanceC<distanceA))
        {x=0;
            y=distanceC+0.5;
        }
        if((distanceB==distanceD)&&(distanceC>distanceA))
               {x=0;
                   y=-1*(distanceA+0.5);
               }
        if((distanceA==distanceC)&&(distanceB<distanceD))
              {y=0;
                  x=-1*(distanceB+0.5);
              }
        if((distanceA==distanceC)&&(distanceB>distanceD))
                    {y=0;
                        x=distanceD+0.5;
                    }
   }
       else if(touchCount == 5){
        distanceLab.text = [NSString stringWithFormat:@"x: %f y: %f",x,y];
        self.sceneView.delegate = self;
        self.sceneView.showsStatistics = YES;
        /// 自动点亮默认光源场景
        self.sceneView.autoenablesDefaultLighting = true;
        /// 箭头添加子节点
        [self.arrow addChildNode:[self loadNodeWithName:@"arrow"]];
        /// 目标节点添加子节点
        [self.target addChildNode:[self loadNodeWithName:@"pointer"]];
        /// ARSceneView添加目标节点
        [self.rootNode addChildNode:self.target];
        /// 更新目标位置
        [self updateTargetPosition];
        /// 添加箭头节点, 更新箭头位置
        [self addArrow];
        //  distanceLab.text = [NSString stringWithFormat:@" accuracy : %.1f",beacon.accuracy];
        //  [self updateTargetPosition];
    }
    
}
#pragma mark - handleTap
- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    
    
   
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
            NSString *body = [NSString stringWithFormat:@"status = %@,uuid = %@,major = %ld,minor = %ld",((state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"),bregion.proximityUUID.UUIDString,[bregion.major integerValue],[bregion.minor integerValue]];
            localNotification.body = body;
            localNotification.soundName = nil;
            localNotification.delayTimeInterval = 0.0;
            [localNotification pushLocalNotification];
        }
    }
}

@end
