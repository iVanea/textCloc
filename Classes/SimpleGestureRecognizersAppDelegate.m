#import "SimpleGestureRecognizersAppDelegate.h"
#import "GestureRecognizerViewController.h"
@implementation SimpleGestureRecognizersAppDelegate

@synthesize window=_window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // DECLARAM LIMBA DE BAZA
    // SETTING BASE LANGUAGE
    // IN USER DEFAULTS
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *language = [userDefaults objectForKey:@"languageDefault"];
   
    if (language != NULL)
    {
        [userDefaults setValue:language  forKey:@"languageDefault"];
    }
    else
    {
        [userDefaults setValue:@"EN"  forKey:@"languageDefault"];
        [userDefaults setInteger:0 forKey:@"indexLanguage"];
    }

    [userDefaults synchronize];
    
    return YES;
    
}
@end
