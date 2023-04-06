//
//  VSBarcodeReaderViewController.m
//  VSBarcodeReader
//
//  Copyright 2009-2023 Vision Smarts SPRL. All rights reserved.
//

#import "VSBarcodeReaderViewController.h"
#import "LiveScannerViewController.h"

@implementation VSBarcodeReaderViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	ean13Switch.on =TRUE;
	ean8Switch.on =FALSE;
	upceSwitch.on =FALSE;
	itfSwitch.on =FALSE;
	c39Switch.on =FALSE;
	c128Switch.on =FALSE;
	codabarSwitch.on =FALSE;
    c93Switch.on =FALSE;
	std2of5Switch.on =FALSE;
    telepenSwitch.on =FALSE;
    gs1Switch.on =FALSE;
    eanPlus2Switch.on =FALSE;
    eanPlus5Switch.on =FALSE;
    qrSwitch.on =TRUE;
    dataMatrixSwitch.on =FALSE;

	// For universal apps, check that:
	// 1. the device has a camera
	// 2. the device runs iOS4.0 or later (for live video capture)
	BOOL hasCamera;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		hasCamera = YES;
	}
	else {
		hasCamera = NO;
	}	
	BOOL hasAVCapture;
	if (NSClassFromString(@"AVCaptureSession") != nil) {
		hasAVCapture = YES;
	}
	else {
		hasAVCapture = NO;
	}	
		
	if ((!hasCamera) || (!hasAVCapture)) {
		_scanButton.enabled = NO;
		_scanButton.title = @"unsupported";
	}
	else {
		self.reader = [[VSBarcodeReader alloc] init];
		self.liveScanner = [[LiveScannerViewController alloc] init];
		self.liveScanner.delegate = self;
		self.liveScanner.reader = self.reader;
        // configure reader with default selections
        [self setSymbologies];
	}
}

// Enable or disable the various symbologies according to switches
- (IBAction) setSymbologies {
	int symbologies = 0;
	if (ean13Switch.on)        symbologies |= kVSEAN13_UPCA;
    if (eanPlus2Switch.on)     symbologies |= kVSEANPlus2;
    if (eanPlus5Switch.on)     symbologies |= kVSEANPlus5;
	if (upceSwitch.on)         symbologies |= kVSUPCE;
	if (ean8Switch.on)         symbologies |= kVSEAN8;
	if (itfSwitch.on)          symbologies |= kVSITF;
	if (c39Switch.on)          symbologies |= kVSCode39;
	if (c128Switch.on)         symbologies |= kVSCode128;
	if (codabarSwitch.on)      symbologies |= kVSCodabar;
	if (c93Switch.on)          symbologies |= kVSCode93;
	if (std2of5Switch.on)      symbologies |= kVSStd2of5;
    if (telepenSwitch.on)      symbologies |= kVSTelepen;
    if (gs1Switch.on)          symbologies |= kVSDatabarOmnidirectional | kVSDatabarLimited | kVSDatabarExpanded;
    if (qrSwitch.on)           symbologies |= kVSQRCode;
    if (dataMatrixSwitch.on)   symbologies |= kVSDataMatrix;
	self.liveScanner.symbologies = symbologies;
}
	

// When scan button is pressed, present live scanner view and start it
- (IBAction)startScanner {
    self.liveScanner.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.liveScanner animated:YES completion:nil];
    [self.liveScanner startLiveDecoding];
}

- (void)dismissLiveScanner {
    [self.liveScanner dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)numericFromTelepen:(NSString*)barcode {
    NSMutableString* numString = [NSMutableString new];
    for (int i=0; i<[barcode length]; i++) {
        unichar c = [barcode characterAtIndex:i];
        if ((c>=27) && (c<=126)) [numString appendFormat:@"%02d", (int)c-27];
        else if ((c>=17) && (c<=26)) {
            if (i == [barcode length]-1) {
                [numString appendFormat:@"%1dX", (int)c-17];
            }
            else {
                return nil;
            }
        }
        else {
            return nil;
        }
    }
    return numString;
}

// Replace non printing caracters with hexadecimal representation, add numerical Telepen if any
- (NSString*)barcodeForDisplay:(NSString*)barcode withSymbology:(NSInteger)symbology {
    NSMutableString* displayString = [NSMutableString new];
    for (int i=0; i<[barcode length]; i++) {
        unichar c = [barcode characterAtIndex:i];
        if ((32 <= c) && (c <= 127)) {
            [displayString appendFormat:@"%C", c];
        }
        else {
            [displayString appendFormat:@"{0x%X}", (int)c];
        }
    }
    // Append numeric representation of Telepen if any
    if (symbology == kVSTelepen) {
        NSString* numeric = [self numericFromTelepen:barcode];
        if (numeric) {
            [displayString appendFormat:@"\n(%@)", numeric];
        }
    }
    return displayString;
}


// Barcode has been read successfully
- (void)barcodeFound:(NSString*)barcode withSymbology:(NSInteger)symbology {
	_resultsLabel.text = [self barcodeForDisplay:barcode withSymbology:symbology];
	if ([_resultsLabel.text length]>30) _resultsLabel.font = [_resultsLabel.font fontWithSize:18];
	else _resultsLabel.font = [_resultsLabel.font fontWithSize:30];
	switch (symbology) {
		case kVSEAN13_UPCA:
			formatLabel.text = @"EAN-13";
			break;
        case kVSEANPlus2:
            formatLabel.text = @"EAN+2";
            break;
        case kVSEANPlus5:
            formatLabel.text = @"EAN+5";
            break;
		case kVSEAN8:
			formatLabel.text = @"EAN-8";
			break;
		case kVSUPCE:
			formatLabel.text = @"UPC-E";
			break;
		case kVSITF:
			formatLabel.text = @"ITF";
			break;
		case kVSCode39:
			formatLabel.text = @"Code 39";
			break;
		case kVSCode128:
			formatLabel.text = @"Code 128";
			break;
		case kVSCodabar:
			formatLabel.text = @"Codabar";
			break;
		case kVSCode93:
			formatLabel.text = @"Code 93";
			break;
		case kVSStd2of5:
			formatLabel.text = @"Std 2of5";
			break;
        case kVSTelepen:
            formatLabel.text = @"Telepen";
            break;
        case kVSDatabarOmnidirectional:
            formatLabel.text = @"GS1 Databar Omnidirectional";
            break;
        case kVSDatabarLimited:
            formatLabel.text = @"GS1 Databar Limited";
            break;
        case kVSDatabarExpanded:
            formatLabel.text = @"GS1 Databar Expanded";
            break;
        case kVSQRCode:
            formatLabel.text = @"QR";
            break;
        case kVSDataMatrix:
            formatLabel.text = @"DataMatrix";
            break;
		default:
			break;
	}
	[self performSelector:@selector(dismissLiveScanner) withObject:nil afterDelay:0.2];
}
	
// User has cancelled
- (void)liveScannerDidCancel {
	_resultsLabel.text = @"cancelled";
	formatLabel.text  = @"";
	[self performSelector:@selector(dismissLiveScanner) withObject:nil afterDelay:0.2];
}

- (void)didReceiveMemoryWarning {
	// we don't want to deallocate this view
}

@end
