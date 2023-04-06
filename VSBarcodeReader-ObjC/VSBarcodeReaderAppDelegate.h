//
//  VSBarcodeReaderAppDelegate.h
//  VSBarcodeReader
//
//  Copyright 2009-2023 Vision Smarts SPRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSBarcodeReaderViewController;

@interface VSBarcodeReaderAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet VSBarcodeReaderViewController *viewController;

@end

