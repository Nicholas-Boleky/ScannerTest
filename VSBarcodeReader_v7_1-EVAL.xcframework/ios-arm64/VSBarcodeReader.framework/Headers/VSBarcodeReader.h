//
//  VSBarcodeReader.h
//  VSBarcodeReader
//
//  Created by Benoit Maison on 12/04/2022.
//  Copyright © 2022 Benoit Maison. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for VSBarcodeReader.
FOUNDATION_EXPORT double VSBarcodeReaderVersionNumber;

//! Project version string for VSBarcodeReader.
FOUNDATION_EXPORT const unsigned char VSBarcodeReaderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <VSBarcodeReader/PublicHeader.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <CoreVideo/CoreVideo.h>

typedef NS_ENUM(NSInteger, VSSymbologies)   {
    // 1D symbologies
    kVSEAN13_UPCA = 0x0001,
    kVSEAN8       = 0x0002,
    kVSUPCE       = 0x0004,
    kVSITF        = 0x0008,
    kVSCode39     = 0x0010,
    kVSCode128    = 0x0020,
    kVSCodabar    = 0x0040,
    kVSCode93     = 0x0080,
    kVSStd2of5    = 0x0100,
    kVSTelepen    = 0x0200,
    kVSDatabarOmnidirectional    = 0x0400,
    kVSDatabarLimited            = 0x0800,
    kVSDatabarExpanded           = 0x1000,
    kVSEANPlus2  = 0x2000,
    kVSEANPlus5  = 0x4000,

    // 2D symbologies
    kVSQRCode     = 0x08000,
    kVSDataMatrix = 0x10000
};

typedef NS_ENUM(NSInteger, VSQRMode) {
    kVSQRNumericMode = 1,
    kVSQRAlphaMode   = 2,
    kVSQRByteMode    = 4,
    kVSQRKanjiMode   = 8,
};

// =====================================================
// Class VSBarcodeData holding the data belonging to one found barcode
@interface VSBarcodeData : NSObject

// For all symbologies: the barcode symbology (VSSymbologies)
@property NSInteger symbology;

// For all symbologies: the barcode text
// For QR: assuming UTF8 encoding (may be nil if not)
// For DataMatrix: assuming Iso-Latin-1 encoding  (may be nil if not)
@property NSString* text;

// For QR and DataMatrix: the data content
@property NSData* data;

// For QR and DataMatrix: the raw data content
@property NSData* bits;

// For QR and DataMatrix: Structured Append values
@property NSInteger sequenceLength;
@property NSInteger sequencePostion;
@property NSInteger sequenceChecksum;

// For QR: bit mask of the modes (VSQRMode) present in the data
@property NSInteger mode;

@end
// =====================================================


@interface VSBarcodeReader : NSObject {
}

// initializes the reader
-(id) init;

// reset the reader before reading new code
-(void) reset;

// Gives next image buffer of video stream to decode in any direction
//
// Image buffer is normally obtained from AVCaptureSession
// Pixel Format of Image buffer MUST BE either:
// -420v (preferably - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
// -2vuy (iPhone 3G  - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_422YpCbCr8)
// -BGRA (deprecated - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_32BGRA)
//
// return value: (NSString*) barcode data if code has been read,
//                           nil if more images are needed
//
// readFromImageBufferOmnidirectional:(CVImageBufferRef) image buffer from video capture
//
// landscapeMode:(BOOL)landscape : look for a barcode in landscape mode (bars parallel to the short side of the image)
//                                 if true, the readHeight:, from: and to: parameters refer to the landscape image
//
// symbologies:(int)symbologies : OR'ed values from the VSSymbologies enum (defined above)
//                                the symbologies to attempt reading
//                                for example, pass 0x01|0x08 (0x09) to decode EAN13 and ITF
//
// lineStart:(CGPoint*) OUTPUT VALUE: one extremity (at edge of screen) of the line where a barcode has been detected (in image coordinates)
//
// lineEnd:(CGPoint*) OUTPUT VALUE: other extremity (at edge of screen) of the line where a barcode has been detected (in image coordinates)
//
// from:(float*) OUTPUT VALUE : distance from left edge of barcode to
//                              start of line if detected, relative to line length
//                             -1.0 otherwise
// to:(float*) OUTPUT VALUE   : distance from right edge of barcode to
//                              start of line if detected, relative to line length
//                              -1.0 otherwise
//
// foundSymbology:(int*)foundSymbology OUTPUT VALUE :
//                                one value from the VSSymbologies enum (defined above)
//                                the symbology of the barcode that has been read
//                                0 is no barcode read
//
-(NSString*) readFromImageBufferOmnidirectional:(CVImageBufferRef)imageBuffer symbologies:(int)symbologies lineStart:(CGPoint*)start lineEnd:(CGPoint*)end from:(float*)fromLeft to:(float*)toRight foundSymbology:(int*)foundSymbology;


// Gives next image buffer of video stream to decode in any direction
// Current version only returns the first barcode found
// Future version will return all barcodes found in image
//
// Image buffer is normally obtained from AVCaptureSession
// Pixel Format of Image buffer MUST BE either:
// -420v (preferably - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
// -2vuy (iPhone 3G  - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_422YpCbCr8)
// -BGRA (deprecated - video settings kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_32BGRA)
//
// return value: (NSArray*) of VSBarcodeData* (defined above) if code has been read,
//                          or array of size zero if no code has been found and more images are needed
//
// readFromImageBufferMultiple:(CVImageBufferRef) : image buffer from video capture
//
// symbologies:(int)symbologies : OR'ed values from the VSSymbologies enum (defined above)
//                                the symbologies to attempt reading
//                                for example, pass 0x01|0x08 (0x09) to decode EAN13 and ITF
//
// inRectFrom:(CGPoint)topLeft : top left of sub-image rectangle where to look for barcodes
//                               in normalized (x=0..1, y=0..1) image coordinates
//                               regardless of UI orientation (0,0) is upper left of image, (1,1) is bottom right.
//                               use (0,0) to read entire image
//
// to:(CGPoint)bottomRight : bottom right of sub-image rectangle where to look for barcodes
//                           use (1,1) to read entire image
//
-(NSArray*) readFromImageBufferMultiple:(CVImageBufferRef)imageBuffer symbologies:(int)symbologies  inRectFrom:(CGPoint)topLeft to:(CGPoint)bottomRight;

@end
