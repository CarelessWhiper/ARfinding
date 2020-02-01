
#import "TestViewController.h"
#import "registerAppDelegate.h"
#import "FirstViewController.h"
@interface TestViewController ()

@end

@implementation TestViewController
@synthesize database;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    //下次再登陆的时候就可以直接从NSUserDefaults里面读取上次登陆的信息

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textUser resignFirstResponder];
    [self.textPassword resignFirstResponder];
}

- (IBAction)exitClick:(id)sender {
    NSString* userName=_firstValue;
    NSString* password=self.textPassword.text;
    if (([userName length]*[password length])==0) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Not Null" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Other", nil];
        [alert show];
        
        return;
    }
    if ([database open]) {
        [database beginTransaction];//开启事务
        FMResultSet* result=[database executeQuery:@"select * from users where userName=? and pwd=?",userName,password];
        if ([result next]) {
             BOOL success=[database executeUpdate:@"insert into users(userName,pwd) values(?,?)",userName,password];
            if (success) {
                //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"succefully" message:@"insert succefully" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                //[alert show];
               NSLog(@"the result name = %@ password = %@",[result stringForColumn:@"userName"],[result stringForColumn:@"pwd"]);
               UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"succefully" message:@"login succeed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
               [alert show];
               
                
            }else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"i am sorry" message:@"insert failed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
            }
        }
        else
        {
            BOOL success=[database executeUpdate:@"insert into users(userName,pwd) values(?,?)",userName,password];
            if (success) {
               // UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"succefully" message:@"insert succefully" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                //[alert show];
                NSLog(@"the result name = %@ password = %@",[result stringForColumn:@"userName"],[result stringForColumn:@"pwd"]);
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"succefully" message:@"login succeed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alert show];
                
            }else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"i am sorry" message:@"insert failed" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
            }
        }
        [database commit];
        [database close];
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
