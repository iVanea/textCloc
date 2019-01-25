
#import "GestureRecognizerViewController.h"

@implementation GestureRecognizerViewController
@synthesize swipeLeftRecognizer=_swipeLeftRecognizer;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    alphaForBrightness = 1;
    isShowSeconds = NO;
    /*
     Create an image view to display the gesture description.
     */
    muttableDictionary = [[NSMutableDictionary alloc] init];
    [self functionAddIndicatorOfColor];
    [self functionUpdateFromThePlist];
    [self functionUpdateColorFromPlist];
    [self functionChangeColor];
    
    if (IS_IPHONE_5) {
        viewWithWordsClock.frame =  CGRectMake(0, 0, 320, 568);
        imageViewBarColor.frame =  CGRectMake(0, 550, 320, 18);
        viewWithText.frame = CGRectMake(8, 150, 300,300);
        viewForStars.frame = CGRectMake(8, 125, 300,300);
        imageViewTextSetColor.frame = CGRectMake(86, 450, 147,8);
    }
    
    if (IS_IPAD) {
        [self functionAddCharOnIPadScreen];
    }
    else{
        [self functionAddCharOnScreen];
    }
    


}

- (void)viewDidUnload {
    [[UIScreen mainScreen] setBrightness:0.85];
    viewWithWordsClock = nil;
    muttableDictionary = nil;
    
    [super viewDidUnload];
	self.swipeLeftRecognizer = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Support all orientations.
    return YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the segmented control.
    return YES;
}
#pragma mark -
#pragma mark SHAKE

-(BOOL) canBecomeFirstResponder
{
    /* Here, We want our view (not viewcontroller) as first responder 
     to receive shake event message  */
    return YES;
}

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.subtype==UIEventSubtypeMotionShake)
    {
        // Code at shake event
        
        [self functionChangeColor];
        [self performSelector:@selector(functionShowCharacters) withObject:nil];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(functionCurrentTime) userInfo:nil repeats:YES];
    [self becomeFirstResponder];  // View as first responder
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    int i = [[usrDef objectForKey:@"indexColor"]intValue];
    i = i-1;
    [usrDef setInteger:i forKey:@"indexColor"];
    [usrDef synchronize];
}

#pragma mark -
#pragma mark Responding to gestures

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSUInteger numTaps = [[touches anyObject] tapCount];
	if(numTaps >= 2) {
		if (numTaps == 2) {
            NSLog(@"%d-touches",numTaps);
//            [self functionClearScreen];
            if (isShowSeconds) {
                isShowSeconds = NO;
            }
            else{
                isShowSeconds=YES;
            }
		}
	}
    UITouch *touch = [touches anyObject]; 
    pointTouchStarted = [touch locationInView:self.view];
}


- (void)touchesMoved: (NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    if (alphaForBrightness > 0.15 && currentPoint.y > pointTouchStarted.y) {
        
        alphaForBrightness -= 0.01;
        
    } else if (alphaForBrightness <0.95 && currentPoint.y < pointTouchStarted.y) {
        
        alphaForBrightness += 0.01;
        
    }
    [[UIScreen mainScreen] setBrightness:alphaForBrightness];
}

// this action choose language
- (IBAction)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger indexLanguage =  [[userDefaults objectForKey:@"indexLanguage"]intValue];
    //    NSLog(@"Index Language %d", indexLanguage);

    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if(indexLanguage <= 0) {
            [self functionSetLanguage:5]; 
        }else{ 
            indexLanguage = indexLanguage-1;
            [self functionSetLanguage:indexLanguage];
        }
    }
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        if(indexLanguage >= 5){
            [self functionSetLanguage:0];
        }else{
            indexLanguage = indexLanguage+1;
            [self functionSetLanguage:indexLanguage];
        }
    }
    
    [self functionUpdateFromThePlist];
    [self functionShowCharacters];
    [self functionShowAbreviatureLanguage];
    [self performSelector:@selector(functionRefreshTimer) withObject:nil afterDelay:2.0];
    
}

#pragma mark Functions
#pragma mark ------------
//FUNCTIONS
-(void)functionCurrentTime{
    
    NSDate *localTime = [NSDate date];   
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:localTime];
    
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    
    NSString *language = [self functionWhatALanguage];
    if (minute > 30 && ![language isEqualToString:@"RUS"]){
        hour++;
    }
    
    if (hour > 11) {
        hour = hour - 12;
    }
    else{
        if ([language isEqualToString:@"FR"] && hour == 0){
            hour = 12;
        }
    }
    
    if (!isShowSeconds) {
        [self functionTransformTimeToWord_Hour:hour Minute:minute];
        [self functionShowStarsEquivalentForMinute:minute];
    }
    else{
        [self functionShowSeconds:second];
    }
}










-(void)functionShowSeconds:(NSInteger)seconds{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SEC" ofType:@"plist"];
    NSMutableDictionary *myDicSecunde = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    int unitazziSeconds = seconds%10;
    int zeciSeconds = seconds / 10;
    
    NSArray  *arrayUnitazziSecconds = [myDicSecunde objectForKey:[NSString stringWithFormat:@"%d",unitazziSeconds]];
    NSArray  *arrayZeciSecconds = [myDicSecunde objectForKey:[NSString stringWithFormat:@"%d",zeciSeconds]];
    [self functionColorReset];
    for (int i = 0; i <20; i++) {
        if (i < [arrayUnitazziSecconds count]) {
            int j  =  [[NSString stringWithFormat:@"%@",arrayUnitazziSecconds[i]]intValue];
            UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
            lbl.textColor = [UIColor whiteColor];
        }
        if (i < [arrayZeciSecconds count]) {
            int j  =  [[NSString stringWithFormat:@"%@",arrayZeciSecconds[i]]intValue]-6;
            UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
            lbl.textColor = [UIColor whiteColor];
        }
    }
    
    }








-(void)functionTransformTimeToWord_Hour:(NSInteger)hour Minute:(NSInteger)minute
{
    if (oldMinute != minute) {
        [self functionColorReset];
        
        NSString *language = [self functionWhatALanguage];

        NSMutableDictionary *dictWithHR = [muttableDictionary objectForKey:@"HR"];
        NSMutableDictionary *dictWithMinute = [muttableDictionary objectForKey:@"MIN"];
        
        
        NSArray *arrIT = [muttableDictionary objectForKey:@"IT"];
        
        if ([language isEqualToString:@"ITA"] || [language isEqualToString:@"ES"]) {
            if (hour == 1) {
                arrIT = [muttableDictionary objectForKey:@"IT1"];
            }
        }
        
        
        NSArray *arrMIN = [dictWithMinute objectForKey:@"MIN"];

        NSArray *arrHour =[dictWithHR objectForKey:[NSString stringWithFormat:@"%02d",hour]];
        NSArray *arrMinute = [dictWithMinute objectForKey:[NSString stringWithFormat:@"%02d",(minute - (minute % 5))]];
        
        
        NSArray *toString;
        if (minute <= 30) {
            toString = [muttableDictionary objectForKey:@"PAST"];
        }else{
            toString = [muttableDictionary objectForKey:@"TO"];
        }
        if (minute == 0) {
            toString=nil;
        }
        
        NSArray *arrayForStringHour;
        if ([language isEqualToString:@"RUS"] || [language isEqualToString:@"FR"]) {
            if (hour>1 && hour<5) {
                arrayForStringHour = [dictWithMinute objectForKey:@"200"];
            }
            if (hour==1) {
                arrayForStringHour = [dictWithMinute objectForKey:@"100"];
            }
            if (hour<1 || hour>5) {
                arrayForStringHour = [dictWithMinute objectForKey:@"00"];
            }
        }
        
        for (int i = 0; i<15; i++) {
            if (i < [arrMinute count]) {
                int j  =  [[NSString stringWithFormat:@"%@",arrMinute[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
            
            if (i < [arrHour count]) {
                int j  =  [[NSString stringWithFormat:@"%@",arrHour[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
            if(i < [arrIT count]) {
                int j  =  [[NSString stringWithFormat:@"%@",arrIT[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
            if(i < [toString count]) {
                int j  =  [[NSString stringWithFormat:@"%@",toString[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
            if( i < [arrMIN count]) {
                int j  =  [[NSString stringWithFormat:@"%@",arrMIN[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
            if( i < [arrayForStringHour count]) {
                int j  =  [[NSString stringWithFormat:@"%@",arrayForStringHour[i]]intValue];
                UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
                lbl.textColor = [UIColor whiteColor];
            }
        }

        oldMinute = minute;
    }
}










-(void)functionChangeColor{
    NSLog(@"change Color!!!");
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    int i = [[usrDef objectForKey:@"indexColor"]intValue];

        if(i >= 10) {
            i = 1;
        }else{
            i = i+1;
        }
    [self functionIndicatorSelectedColor:i];
    [usrDef setInteger:i forKey:@"indexColor"];
    [usrDef synchronize];
    
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc] initWithDictionary:[muttableColorDictionary objectForKey:[NSString stringWithFormat:@"%d",i]]];
    int variableOfColorRed = [[myDict objectForKey:@"bg-red"]intValue];
    int variableOfColorGreen = [[myDict objectForKey:@"bg-green"]intValue];
    int variableOfColorBlue = [[myDict objectForKey:@"bg-blue"]intValue];
    viewWithWordsClock.backgroundColor = [UIColor colorWithRed:variableOfColorRed/255.0 green:variableOfColorGreen/255.0 blue:variableOfColorBlue/255.0 alpha:1];

    red = [[myDict objectForKey:@"t-red"]intValue];
    green = [[myDict objectForKey:@"t-green"]intValue];
    blue = [[myDict objectForKey:@"t-blue"]intValue];
    
    [self functionShowCharacters];
    [self functionRefreshTimer];
}

-(void)functionIndicatorSelectedColor:(NSInteger)indexColor{
    int indice;
    if (indexColor == 3 || indexColor == 4) {
        imageViewTextSetColor.image = [UIImage imageNamed:@"ipad_text1.png"];
        indice = 1;
    }
    else{
        imageViewTextSetColor.image = [UIImage imageNamed:@"ipad_text.png"];
        indice = 0;
    }
    
    for (UIImageView *img in viewForColorIndicator.subviews) {
        if (img.tag < indexColor) {
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"round%d_.png",indice]];
        }
        else{
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"round%d.png",indice]];
        }
    }
}

-(void)functionAddIndicatorOfColor{
    for (int j = 0; j<10; j++) {
        UIImageView *imageCircle = [[UIImageView alloc]initWithFrame:CGRectMake(0+(j*10),0,6.0,6.0)];
        imageCircle.tag = j;
        [viewForColorIndicator addSubview:imageCircle];
    }
}

-(void)functionSetLanguage:(NSInteger)indexLanguage{
//    NSLog (@"s-a apelat FunctionSetLanguage %d", indexLanguage);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:indexLanguage forKey:@"indexLanguage"];
    
    switch (indexLanguage) {
        case 0:
            [userDefaults setValue:@"EN"  forKey:@"languageDefault"];
            break;
        case 1:
            [userDefaults setValue:@"ES"  forKey:@"languageDefault"];
            break;
        case 2:
            [userDefaults setValue:@"FR"  forKey:@"languageDefault"];
            break;
        case 3:
            [userDefaults setValue:@"DE"  forKey:@"languageDefault"];
            break;
        case 4:
            [userDefaults setValue:@"ITA"  forKey:@"languageDefault"];
            break;
        case 5:
            [userDefaults setValue:@"RUS"  forKey:@"languageDefault"];
            break;
        default:
            break;
    }
    
    [userDefaults synchronize];
}

-(NSString *)functionWhatALanguage{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *language = [userDefaults objectForKey:@"languageDefault"];
    return language;
}


//PLIST 
-(void)functionUpdateFromThePlist{
    NSString *stringWithLanguage = [self functionWhatALanguage];
    NSLog (@"This language is selected: %@", stringWithLanguage);
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"EN" ofType:@"plist"];
    NSString *path = [[NSBundle mainBundle] pathForResource:stringWithLanguage ofType:@"plist"];
    NSMutableDictionary *myDic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    muttableDictionary = myDic;
    //    NSLog(@"Dictionary: %@", muttableDictionary.description);
}

-(void)functionUpdateColorFromPlist{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"color" ofType:@"plist"];
    NSMutableDictionary *myDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    muttableColorDictionary = myDict;
    //    NSLog(@"Dictionary WITH COLOR %@", muttableColorDictionary.description);
}
// END WORK WITH PLIST


-(void)functionAddCharOnIPadScreen{
    NSString *language = [self functionWhatALanguage];
    NSArray *arrayWithBackgroundText = [NSArray arrayWithArray:[muttableDictionary objectForKey:[NSString stringWithFormat:@"%@",language]]];
    for (int i = 0; i<110; i++) {
        //        NSLog(@"linie: %d - coloana: %d", i/11, i%11);
        int y = i/11;
        int x = i%11;
        UILabel *labelForLeters = [[UILabel alloc] initWithFrame:CGRectMake(x*68, y*68, 50, 50)];
        labelForLeters.text = [NSString stringWithFormat:@"%@",arrayWithBackgroundText[i]];
//        labelForLeters.text = [NSString stringWithFormat:@"%d",i+1];
        labelForLeters.tag = i+1;
        labelForLeters.backgroundColor = [UIColor clearColor];
        labelForLeters.font = [UIFont fontWithName: @"Arial" size:48];
        labelForLeters.textAlignment = UITextAlignmentCenter;
        labelForLeters.textColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        
        [viewWithText addSubview:labelForLeters];
    }
    
    //ADD SCREEN STARS
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    
    int i = [[usrDef objectForKey:@"indexColor"]intValue];
    for (int j = 0; j<4; j++) {
        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(0+(j*50),0,49.0,49.0)];
        imageStar.tag = j;
        imageStar.image = [UIImage imageNamed:[NSString stringWithFormat:@"star_%d",i]];
        [viewForStars addSubview:imageStar];
    }
    [self functionCurrentTime];
}

-(void)functionAddCharOnScreen{
    //ADD ON SCREEN CHARACTERS
    NSString *language = [self functionWhatALanguage];
    NSArray *arrayWithBackgroundText = [NSArray arrayWithArray:[muttableDictionary objectForKey:[NSString stringWithFormat:@"%@",language]]];
    for (int i = 0; i<110; i++) {
        //        NSLog(@"linie: %d - coloana: %d", i/11, i%11);
        int y = i/11;
        int x = i%11;
        UILabel *labelForLeters = [[UILabel alloc] initWithFrame:CGRectMake(x*28, y*28, 22, 22)];
        labelForLeters.text = [NSString stringWithFormat:@"%@",arrayWithBackgroundText[i]];
//        labelForLeters.text = [NSString stringWithFormat:@"%d",i+1];
        
        labelForLeters.tag = i+1;
        labelForLeters.backgroundColor = [UIColor clearColor];
        labelForLeters.font = [UIFont fontWithName: @"Arial" size:20];
        labelForLeters.textAlignment = UITextAlignmentCenter;
        labelForLeters.textColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        
        [viewWithText addSubview:labelForLeters];
    }
    
    //ADD SCREEN STARS
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    
    int i = [[usrDef objectForKey:@"indexColor"]intValue];
    for (int j = 0; j<4; j++) {
        UIImageView *imageStar = [[UIImageView alloc]initWithFrame:CGRectMake(0+(j*36),0,23.0,23.0)];
        imageStar.tag = j;
        imageStar.image = [UIImage imageNamed:[NSString stringWithFormat:@"star_%d",i]];
        [viewForStars addSubview:imageStar];
    }
    [self functionCurrentTime];
}

-(void)functionClearScreen{
    for (UILabel *lbl in viewWithText.subviews) {
        lbl.text = @"";
    }
    
    
    for (UIImageView *img in viewForStars.subviews) {
        img.hidden = YES;
    }
    
}

-(void)functionShowAbreviatureLanguage{
    NSString *language = [self functionWhatALanguage];
    NSArray *arrayWithAbreviatureLanguage = [muttableDictionary objectForKey:[NSString stringWithFormat:@"%@1",language]];
    for (int i = 0; i < [arrayWithAbreviatureLanguage count]; i++) {
        int j  =  [[NSString stringWithFormat:@"%@",arrayWithAbreviatureLanguage[i]]intValue];
         UILabel *lbl = (UILabel *)[self.view viewWithTag:j];
         lbl.textColor = [UIColor whiteColor];
    }
}

-(void)functionShowStarsEquivalentForMinute:(NSInteger)minute{
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    int i = [[usrDef objectForKey:@"indexColor"]intValue];
    for (UIImageView *img in viewForStars.subviews) {
        if (img.tag < (minute % 5)) {
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"star_%d_",i]];
        }
        else{
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"star_%d",i]];
        }
    }
}

-(void)functionShowCharacters{
    
    [self functionClearScreen];
    NSString *language = [self functionWhatALanguage];
    NSArray *arrayWithBackgroundText = [NSArray arrayWithArray:[muttableDictionary objectForKey:[NSString stringWithFormat:@"%@",language]]];
    for (int i = 0; i<110; i++) {
        UILabel *labelForLeters = (UILabel *)[viewWithText viewWithTag:i+1];
        labelForLeters.text = [NSString stringWithFormat:@"%@",arrayWithBackgroundText[i]];
        labelForLeters.textColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    }
    
    
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    int i = [[usrDef objectForKey:@"indexColor"]intValue];
    for (UIImageView *img in viewForStars.subviews) {
        img.image = [UIImage imageNamed:[NSString stringWithFormat:@"star_%d",i]];
        [img setHidden:NO];
    }
}

-(void)functionColorReset{
    //FOR NEW VARIABLE ON SCREEN, I CLEAR ALL VARIABLE COLOR
    for (UILabel *lbl in viewWithText.subviews) {
        lbl.textColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    }
}

- (IBAction)buttonInfo:(UIButton *)sender{
    NSLog(@"button was pressed");
}

-(void)functionRefreshTimer{
    oldMinute--;
}

@end
