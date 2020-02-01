//
//  TestViewController.h
//  ss
//
//  Created by student on 14-3-26.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface TestViewController : UIViewController
@property(nonatomic,retain)FMDatabase* database;
@property (retain, nonatomic) IBOutlet UITextField *textUser;
@property (retain, nonatomic) IBOutlet UITextField *textPassword;
@property(nonatomic,retain) NSString *firstValue ;
- (IBAction)okClick:(id)sender;
- (IBAction)exitClick:(id)sender;

@end
