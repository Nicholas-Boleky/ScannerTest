//
//  LiveScannerViewController.m
//  VSBarcodeReader
//
//  Copyright 2010-2023 Vision Smarts SPRL. All rights reserved.
//

#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#import <AudioToolbox/AudioToolbox.h>

#import "LiveScannerViewController.h"
#import "BarcodeHelper.h"

#define FRAMESAMPLING 2

@implementation LiveScannerViewController

- (id)init {
	self = [super init];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    // start with default camera (back), image will not be flipped
    self.currentCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    flippedImage = NO;
    
	// Use audio sevices to create the beep sound
	NSString *path = [NSString stringWithFormat:@"%@%@",
					  [[NSBundle mainBundle] resourcePath],
					  @"/beep.wav"];
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);

    frameNumber = 0;
    
	/*We intialize the capture (iOS5: if there is a camera) */
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[self initCapture];
	}
	
	isVisible = NO;	
}

- (void)viewDidLayoutSubviews
{
    // Because view may have been resized from NIB (iPhone 5)
    self.prevLayer.frame = self.previewView.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.captureSession beginConfiguration];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    [self.captureSession commitConfiguration];
}

- (void)viewDidAppear:(BOOL)animated {
	isVisible = YES;
	isScanning = YES;

    long numDevices = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
	if (numDevices > 1) {
		NSLog(@"multiple cameras");
		_flipButton.hidden = NO;
		_flipButton.selected = NO;
	}
	else {
		NSLog(@"just one camera");
		_flipButton.hidden = YES;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	isVisible = NO;
    // Stop capture in case view was dismissed
    [self stopCapture];
}

-(IBAction)flipCamera {
	NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	if (isScanning && ([devices count]>1)) {
        
		[self.captureSession beginConfiguration];
        
		[self.captureSession removeInput:[[self.captureSession inputs] objectAtIndex:0] ];
        
		if (self.currentCaptureDevice == [devices objectAtIndex:0]) {
			self.currentCaptureDevice = [devices objectAtIndex:1];
            flippedImage = YES;
		}
		else {
			self.currentCaptureDevice = [devices objectAtIndex:0];	
            flippedImage = NO;
		}
        
		AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
											  deviceInputWithDevice:self.currentCaptureDevice 
											  error:nil];
		
		[self.captureSession addInput:captureInput];
		
		[self.captureSession commitConfiguration];
    }
}

-(IBAction)cancel {
	[self stopCapture];
	[self.delegate liveScannerDidCancel];
}

- (void)initCapture {
	// Setup the input
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
										  deviceInputWithDevice:self.currentCaptureDevice
										  error:nil];
	// Setup the output
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init]; 
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	NSNumber* value;

    // detect iPhone 3G as it does not support planar YUV Pixel Format
	BOOL is3G = FALSE;
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	if ((size==10)&&(!strncmp(machine,"iPhone1,2",10))) is3G=TRUE;
	free(machine);
    
    
	if (is3G) {
		// Set the video output to store frame in interleaved YUV (iPhone 3G)
		value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8]; 
	}
	else {
		// Set the video output to store frame in planar YUV (all other devices)
		value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]; 
	}
	 	
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings]; 

	// Create a capture session
	self.captureSession = [[AVCaptureSession alloc] init];
	
    // Recommended setting 'medium' for UPC/EAN scanning:
    // May need to change resolution if scanning other symbologies
    // self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    // High resolution is useful for long barcodes or codes that are very small
    // Only use the 'high' setting if necessary to read large barcodes (with many bars)
	// or small barcodes from a greater distance (in order to be sufficiently sharp)
	// because the frame rate will be lower than with the 'medium' setting
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;

	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];

	// Setup the preview layer
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
	self.prevLayer.frame = self.previewView.bounds;
	self.prevLayer.videoGravity = AVLayerVideoGravityResize; // image may be slightly distorted, but red bar position will be accurate
	[self.previewView.layer addSublayer: self.prevLayer];
    
}

- (void)stopCapture {
	isScanning = NO;
	[self.captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{	
	// do not attempt decoding before live image is visible to user
	// do not attempt decoding after barcode has been found (but video capture is not yet stopped)
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);  
    // NSLog(@"got image w=%d h=%d bpr=%d",(int)CVPixelBufferGetWidth(imageBuffer),(int) CVPixelBufferGetHeight(imageBuffer), (int) CVPixelBufferGetBytesPerRow(imageBuffer));
    frameNumber += 1;
	if (isScanning && isVisible && (frameNumber%FRAMESAMPLING == 0) ){
        [self decodeImageOmnidirectional:imageBuffer];
	}
} 


-(void)decodeImageOmnidirectional:(CVImageBufferRef)imgBuf {
    @autoreleasepool {
                
        NSArray* barcodeDataArray = [self.reader readFromImageBufferMultiple:imgBuf symbologies:_symbologies inRectFrom:CGPointMake(0,0) to:CGPointMake(1, 1) ];
        
        // if a barcode has been successfully read
        // stop live scan, beep, return results to main controller		
        if ([barcodeDataArray count] > 0) {

            VSBarcodeData* barcodeData = barcodeDataArray[0];
            NSInteger foundSymbology = barcodeData.symbology;
                
            // Crude trick to avoid misreads in demo when all symbologies are selected.
            // A real app would only enable useful symbologies,
            // and would be able to validate against expected length, etc.
            if (foundSymbology != _symbologies) { // more than one was enabled
                if ((foundSymbology == kVSCodabar) ||
                    (foundSymbology == kVSITF) ||
                    (foundSymbology == kVSCode39)) {
                    if ([barcodeData.text length] < 4) {
                        return;
                    }
                }
            }

            NSString* barcode = barcodeData.text;

            // If QR or DataMatrix, check whether ECI (Extended Channel Interpretation) is present and interpret data accordingly
            if ( (foundSymbology == kVSQRCode || foundSymbology == kVSDataMatrix) ) {
                NSStringEncoding defaultEncoding = (foundSymbology == kVSQRCode) ? NSUTF8StringEncoding : NSISOLatin1StringEncoding;
                barcode = [BarcodeHelper stringWithECIData:barcodeData.data mode: barcodeData.mode encoding: defaultEncoding];
            }

            if (barcode == nil) return;
            
            isScanning = NO;
            [self stopCapture];
            AudioServicesPlaySystemSound(soundID);

            [self.delegate barcodeFound:barcode withSymbology:foundSymbology];
        }	
    }
}

-(void)startLiveDecoding {
	// this sets the position of the red bar on the screen
	// the scan function can look 
	// for the barcode at the right height in the screen capture
	[self.reader reset];
	/// start the video capture
	[self.captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"LiveScannerViewController - memory warning");
	// we don't want to deallocate this view
}


@end
