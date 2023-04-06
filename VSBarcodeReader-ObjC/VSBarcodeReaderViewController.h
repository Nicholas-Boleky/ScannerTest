//
//  VSBarcodeReaderViewController.h
//  VSBarcodeReader
//
//  Copyright 2009-2023 Vision Smarts SPRL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSBarcodeReader/VSBarcodeReader.h"
#import "LiveScannerViewController.h"

@interface VSBarcodeReaderViewController : UIViewController <LiveScannerDelegate, UINavigationControllerDelegate>  {
	IBOutlet UILabel  *formatLabel;
	IBOutlet UISwitch *ean13Switch;
	IBOutlet UISwitch *ean8Switch;
	IBOutlet UISwitch *upceSwitch;
	IBOutlet UISwitch *itfSwitch;
	IBOutlet UISwitch *c39Switch;
	IBOutlet UISwitch *c128Switch;
	IBOutlet UISwitch *codabarSwitch;
	IBOutlet UISwitch *c93Switch;
	IBOutlet UISwitch *std2of5Switch;
    IBOutlet UISwitch *telepenSwitch;
    IBOutlet UISwitch *gs1Switch;
    IBOutlet UISwitch *eanPlus2Switch;
    IBOutlet UISwitch *eanPlus5Switch;
    IBOutlet UISwitch *qrSwitch;
    IBOutlet UISwitch *dataMatrixSwitch;
}

@property (nonatomic, strong) VSBarcodeReader *reader;
@property (nonatomic, strong) LiveScannerViewController *liveScanner;
@property (nonatomic, strong) UILabel *resultsLabel;
@property (nonatomic, strong) UIBarButtonItem *scanButton;

- (IBAction)startScanner;
- (IBAction)setSymbologies;

- (void)barcodeFound:(NSString*)barcode withSymbology:(NSInteger)symbology;
- (void)liveScannerDidCancel;
- (void)dismissLiveScanner;

@end

