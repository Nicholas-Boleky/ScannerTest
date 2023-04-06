//
//  LiveScannerViewController.h
//  VSBarcodeReader
//
//  Copyright 2010-2023 Vision Smarts SPRL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioServices.h>

#import "VSBarcodeReader/VSBarcodeReader.h"

@protocol LiveScannerDelegate
-(void) liveScannerDidCancel;
-(void) barcodeFound:(NSString*)barcode withSymbology:(NSInteger)symbology;
@end

@interface LiveScannerViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	int barpos;
	BOOL isScanning;
	BOOL isVisible;
    BOOL flippedImage;
	SystemSoundID soundID;	
    int frameNumber;
}

@property (nonatomic, unsafe_unretained) id<LiveScannerDelegate> delegate;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, strong) AVCaptureDevice* currentCaptureDevice;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UILabel *helpLabel;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) VSBarcodeReader* reader;
@property (assign) int symbologies;
@property (assign) BOOL beep;

-(IBAction)cancel;
-(IBAction)flipCamera;

-(void)startLiveDecoding;
-(void)initCapture;
-(void)stopCapture;
-(void)decodeImageOmnidirectional:(CVImageBufferRef)imgBuf;


@end
