#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface LocalPush : NSObject


@property (nonatomic, assign) NSInteger applicationIconBadgeNumber;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy) NSString *soundName;

@property (nonatomic, assign) NSTimeInterval delayTimeInterval;

- (void)pushLocalNotification;

@end
