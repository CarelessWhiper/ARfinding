

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "FMDatabase.h"
#import "FMResultSet.h"
@interface DiscoverBeaconViewController : UIViewController
@property(nonatomic,retain)FMDatabase* database;
@property (retain, nonatomic) IBOutlet UITextField *textUser;
@property (retain, nonatomic) IBOutlet UITextField *textPassword;
@property(nonatomic,retain) NSString *firstValue ;
- (IBAction)okClick:(id)sender;
- (IBAction)exitClick:(id)sender;

@end
