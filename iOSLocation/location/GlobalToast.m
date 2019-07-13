//
//  GlobalToast.m
//  location
//


#import "GlobalToast.h"
#import <UIKit/UIKit.h>

@implementation GlobalToast

+ (void)addText:(NSString *)text
{
    UITextView *textView;
    if (![[UIApplication sharedApplication].keyWindow viewWithTag:1111]) {
        textView = [[UITextView alloc] init];
        textView.textColor = [UIColor blueColor];
        textView.font = [UIFont systemFontOfSize:11];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.5, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.5);
        textView.tag = 1111;
        textView.editable = NO;
        
        [[UIApplication sharedApplication].keyWindow addSubview:textView];
    }else
    {
        textView = (UITextView *)[[UIApplication sharedApplication].keyWindow viewWithTag:1111];
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *now = [dateFormat stringFromDate:date];

    textView.text = [NSString stringWithFormat:@"%@\n%@ %@",textView.text,now,text];
    
    if (textView.contentSize.height > textView.frame.size.height) {
        [textView setContentOffset:CGPointMake(0, textView.contentSize.height - textView.frame.size.height) animated:YES];
    }
}

@end
