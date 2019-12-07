// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/com.isklikas.HowDareYou-resources.bundle"
#import <AudioToolbox/AudioToolbox.h>

@interface CUTPowerMonitor : NSObject

@property (nonatomic, readonly) double batteryPercentRemaining;
@property (nonatomic) double currentLevel;
@property (setter=setExternalPowerConnected:, nonatomic) BOOL isExternalPowerConnected;

+ (id)sharedInstance;
- (void)_handlePowerChangedNotificationWithMessageType:(unsigned int)arg1 notificationID:(void*)arg2;
- (BOOL)_updateBatteryConnectedStateWithBatteryEntry:(unsigned int)arg1;
- (void)setCurrentLevel:(double)arg1;
- (void)setExternalPowerConnected:(BOOL)arg1;
- (void)updateBatteryConnectedStateWithBatteryEntry:(unsigned int)arg1;
- (void)updateBatteryLevelWithBatteryEntry:(unsigned int)arg1;
- (BOOL)isExternalPowerConnected;
- (double)batteryPercentRemaining;
@end

@interface SpringBoard : UIApplication
@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:@"SBUIACStatusChangedNotification" object:nil]; 
    
    //This is unnecessary, it seems that SBUIACStatusChangedNotification is Universal.
	//if (@available(iOS 13.0, *)) {
    //	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    //}
    //else {
    //	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:@"SBUIBatteryStatusChangedNotification" object:nil]; /* Lower iOS Versions maybe */
    //	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:@"SBUIACStatusChangedNotification" object:nil]; /* Even lower iOS Versions maybe */
    //}
    %orig;
}

%new
-(void)batteryStatusChanged:(NSNotification *)notification { 
	id powerMonitor = [objc_getClass("CUTPowerMonitor") performSelector:@selector(sharedInstance)];
	NSDictionary *chargingDetails = notification.userInfo;
	BOOL isChargerConnected = [[chargingDetails objectForKey:@"ExternalConnected"] boolValue];
	
	/*
	//For some unknown reason, this returns the opposite of what it should. It works however!
	//It is unreliable though, so userInfo here is preferable. User Info also has the battery percentage, but we ask the system here.
	typedef BOOL (*getChargerConnected)(void*, SEL);
	SEL getChargerConnectedSEL = @selector(isExternalPowerConnected);
	getChargerConnected getChargerConnectedIMP = (getChargerConnected)[objc_getClass("CUTPowerMonitor") instanceMethodForSelector:getChargerConnectedSEL];
	BOOL isChargerNOTConnected = getChargerConnectedIMP((__bridge void*)powerMonitor, getChargerConnectedSEL);
	*/
	
	typedef double (*getpowerPercentage)(void*, SEL);
	SEL getpowerPercentageSEL = @selector(batteryPercentRemaining);
	getpowerPercentage getpowerPercentageIMP = (getpowerPercentage)[objc_getClass("CUTPowerMonitor") instanceMethodForSelector:getpowerPercentageSEL];
	double powerPercentage = getpowerPercentageIMP((__bridge void*)powerMonitor, getpowerPercentageSEL);

	int intPercentage = floor(powerPercentage); //Basically, 100% is 1, anything else is 0.
	if (isChargerConnected && intPercentage == 1) {
		//It is fully charged and plugged in. HOW DARE YOU!
		//NSLog(@"HowDareYou: It is fully charged and plugged in. HOW DARE YOU!");
		NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
		NSString *soundFilePath = [bundle pathForResource:@"how_dare_you" ofType:@"m4a"];
		NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];

		SystemSoundID sounds[10];
		CFURLRef soundURL = (__bridge CFURLRef)soundFileURL;
		AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
		AudioServicesPlaySystemSound(sounds[0]);
	}
	//NSLog(@"HowDareYou: %@", notification);
	//NSLog(@"HowDareYou isChargerConnected: %d powerPercentage: %f", isChargerConnected, powerPercentage);
}

%end