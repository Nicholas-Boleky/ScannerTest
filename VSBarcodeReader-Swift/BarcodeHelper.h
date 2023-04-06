//
//  BarcodeHelper.h
//  VSBarcodeReader
//
//  Copyright © 2017-2023 Vision Smarts. All rights reserved.
//
//

#import <Foundation/Foundation.h>

@interface BarcodeHelper : NSObject



+(NSString *)formatEAN13:(int*)res;

+(NSString *)formatEAN8:(int*)res;

+(NSString *)formatUPCE:(int*)res;

+(NSString *)gatherEAN13:(int*)res;

+(NSString *)gatherEAN8:(int*)res;

+(NSString *)gatherUPCE:(int*)res;

+(NSStringEncoding) stringEncodingForECI:(int)eci;

+(NSUInteger) firstECIMarkerIn:(NSData*)data from:(NSUInteger)pos value:(NSUInteger*)val;

+(NSString*) stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;

+(NSString*) stringWithQRData:(NSData*)data mode:(int)qrMode;

+(NSString*) stringWithECIData:(NSData*)data mode:(NSInteger)qrMode encoding:(NSStringEncoding)encoding;

@end
