//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import <React/RCTEventDispatcher.h>
#endif

@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
  _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
  return _orientation;
}

- (instancetype)init
{
  if ((self = [super init])) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceStatusBarOrientationDidChange:) name:@"UIApplicationDidChangeStatusBarFrameNotification" object:nil];
  }
  return self;

}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"specificOrientationDidChange"
                                              body:@{@"specificOrientation": [self getSpecificOrientationStr:orientation]}];

  [self.bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                              body:@{@"orientation": [self getOrientationStr:orientation]}];

}

- (void)deviceStatusBarOrientationDidChange:(NSNotification *)notification
{
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"uiOrientationDidChange"
                                                body:@{@"uiOrientation": [self getStatusBarOrientationStr:statusBarOrientation]}];

}

- (NSString *)getOrientationStr: (UIDeviceOrientation)orientation {
  NSString *orientationStr;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;
    case UIDeviceOrientationLandscapeLeft:
      orientationStr = @"LANDSCAPE_LEFT";
      break;
    case UIDeviceOrientationLandscapeRight:
      orientationStr = @"LANDSCAPE_RIGHT";
      break;

    case UIDeviceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;

    default:
      // orientation is unknown, we try to get the status bar orientation
      switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
          orientationStr = @"PORTRAIT";
          break;
        case UIInterfaceOrientationLandscapeLeft:
          orientationStr = @"LANDSCAPE_LEFT";
          break;
        case UIInterfaceOrientationLandscapeRight:
          orientationStr = @"LANDSCAPE_RIGHT";
          break;

        case UIInterfaceOrientationPortraitUpsideDown:
          orientationStr = @"PORTRAITUPSIDEDOWN";
          break;

        default:
          orientationStr = @"UNKNOWN";
          break;
      }
      break;
  }
  return orientationStr;
}

- (NSString *)getStatusBarOrientationStr: (UIInterfaceOrientation)orientation {
  NSString *orientationStr;
  // orientation is unknown, we try to get the status bar orientation
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:

      orientationStr = @"LANDSCAPE";
      break;

    case UIInterfaceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;

    default:
      orientationStr = @"UNKNOWN";
      break;
  }
  return orientationStr;
}

- (NSString *)getSpecificOrientationStr: (UIDeviceOrientation)orientation {
  NSString *orientationStr;
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;

    case UIDeviceOrientationLandscapeLeft:
      orientationStr = @"LANDSCAPE-LEFT";
      break;

    case UIDeviceOrientationLandscapeRight:
      orientationStr = @"LANDSCAPE-RIGHT";
      break;

    case UIDeviceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;

    default:
      // orientation is unknown, we try to get the status bar orientation
      switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationPortrait:
          orientationStr = @"PORTRAIT";
          break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:

          orientationStr = @"LANDSCAPE";
          break;

        case UIInterfaceOrientationPortraitUpsideDown:
          orientationStr = @"PORTRAITUPSIDEDOWN";
          break;

        default:
          orientationStr = @"UNKNOWN";
          break;
      }
      break;
  }
  return orientationStr;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];
  callback(@[[NSNull null], orientationStr]);
}

RCT_EXPORT_METHOD(getSpecificOrientation:(RCTResponseSenderBlock)callback)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getSpecificOrientationStr:orientation];
    callback(@[[NSNull null], orientationStr]);
  });
}

RCT_EXPORT_METHOD(lockToPortrait)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    #if DEBUG
      NSLog(@"Locked to Portrait");
    #endif
    [Orientation setOrientation:UIInterfaceOrientationMaskPortrait];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
      [UIViewController attemptRotationToDeviceOrientation];
    }];
  });
}

RCT_EXPORT_METHOD(lockToLandscape)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    #if DEBUG
      NSLog(@"Locked to Landscape");
    #endif
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getSpecificOrientationStr:orientation];
    if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
      [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
      }];
    } else {
      [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
      }];
    }
  });
}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    #if DEBUG
      NSLog(@"Locked to Landscape Left");
    #endif
      [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
      [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
          [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
          [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
          [UIViewController attemptRotationToDeviceOrientation];
      }];
  });

}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    #if DEBUG
      NSLog(@"Locked to Landscape Right");
    #endif
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeRight];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
      // this seems counter intuitive
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
      [UIViewController attemptRotationToDeviceOrientation];
    }];
  });

}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
  #if DEBUG
    NSLog(@"Unlock All Orientations");
  #endif
  [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
//  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//  delegate.orientation = 3;
}

- (NSDictionary *)constantsToExport
{

  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  NSString *orientationStr = [self getOrientationStr:orientation];

  return @{
    @"initialOrientation": orientationStr
  };
}

@end

