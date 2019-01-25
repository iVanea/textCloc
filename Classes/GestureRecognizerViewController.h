#import <UIKit/UIKit.h>

@interface GestureRecognizerViewController : UIViewController <UIGestureRecognizerDelegate> {
    

//VIEWS
    IBOutlet UIView *viewWithWordsClock;
    IBOutlet UIView *viewWithText;
    IBOutlet UIView *viewForStars;
    IBOutlet UIView *viewForColorIndicator;
//location
    CGPoint pointTouchStarted;
    float alphaForBrightness;
//dictionary for words in different languages    
    NSMutableDictionary *muttableDictionary;        //for letters on background
    NSMutableDictionary *muttableColorDictionary;   //for background color and text color
//images
    IBOutlet UIImageView *imageViewBarColor;
    IBOutlet UIImageView *imageViewTextSetColor;
    
//    bool for show secconds
    BOOL isShowSeconds;
    
//    color
    int red,blue,green, oldMinute;
}

//FUNCTIONS
-(void)functionCurrentTime;
-(void)functionTransformTimeToWord_Hour:(NSInteger)hour Minute:(NSInteger)minute;
-(void)functionChangeColor;
-(void)functionSetLanguage:(NSInteger)indexLanguage;
-(void)functionUpdateColorFromPlist;
-(void)functionShowAbreviatureLanguage;
-(void)functionShowCharacters;
-(void)functionColorReset;
-(void)functionRefreshTimer;
-(void)functionIndicatorSelectedColor:(NSInteger)indexColor;
-(void)functionAddIndicatorOfColor;
-(void)functionAddCharOnIPadScreen;
-(void)functionShowSeconds:(NSInteger)seconds;

//touch began
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
//shake
-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

-(void)functionUpdateFromThePlist;
-(NSString *)functionWhatALanguage;
//-(NSString *)function
-(void)functionAddCharOnScreen;
-(void)functionClearScreen;
//PROPERTIES
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;

//ACTIONS
- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer;
- (IBAction)buttonInfo:(UIButton *)sender;

@end

