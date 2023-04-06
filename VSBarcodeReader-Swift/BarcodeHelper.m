//
//  BarcodeHelper.m
//  VSBarcodeReader
//
//  Copyright © 2017-2023 Vision Smarts. All rights reserved.
//
//

#import "BarcodeHelper.h"
#import "VSBarcodeReader/VSBarcodeReader.h"

@implementation BarcodeHelper

+(NSString *)formatEAN13:(int*)res {
    if (res[0]==0) { // UPC
        return [NSString stringWithFormat:@"%d-%d%d%d%d%d-%d%d%d%d%d-%d",
                res[1],res[2],res[3],res[4],res[5],res[6],res[7],res[8],res[9],res[10],res[11],res[12]];
    }
    else {
        return [NSString stringWithFormat:@"%d-%d%d%d%d%d%d-%d%d%d%d%d%d",
                res[0],res[1],res[2],res[3],res[4],res[5],res[6],
                res[7],res[8],res[9],res[10],res[11],res[12]];
    }
}

+(NSString *)formatEAN8:(int*)res {
    return [NSString stringWithFormat:@"%d%d%d%d-%d%d%d%d",
            res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7]];
}

+(NSString *)formatUPCE:(int*)res {
    return [NSString stringWithFormat:@"%d-%d%d%d%d%d%d-%d",
            res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7]];
}

+(NSString *)gatherEAN13:(int*)res {
    return [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d%d%d%d%d%d",
            res[0],res[1],res[2],res[3],res[4],res[5],res[6],
            res[7],res[8],res[9],res[10],res[11],res[12]];
}

+(NSString *)gatherEAN8:(int*)res {
    return [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d",
            res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7]];
}
+(NSString *)gatherUPCE:(int*)res {
    return [NSString stringWithFormat:@"%d%d%d%d%d%d%d%d",
            res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7]];
}

// The following list of ECIs is incomplete and may be partially incorrect.
// It is provided as a starting point for your convenience.
// Please check the ECI definitions that are relevant for your application, if any.
+(NSStringEncoding) stringEncodingForECI:(int)eci
{
    switch(eci) {
        case 0: return  NSISOLatin1StringEncoding;	// 000000	ISO/IEC 15438 Bar code symbology specification-PDF417: Default character set to 1994 specification with GLI rules
        case 1: return 	NSISOLatin1StringEncoding;	// 000001	ISO/IEC 15438 Bar code symbology specification-PDF417: Latin 1 character set to 1994 specification with GLI rules
        case 2: return 	NSISOLatin1StringEncoding;	// 000002	ISO/IEC 15438 Bar code symbology specification-PDF417: Default character set with ECI rules
        case 3: return 	NSISOLatin1StringEncoding;	// 000003	ISO/IEC 8859-1 Latin alphabet No. 1
        case 4: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin2);	        // 000004	ISO/IEC 8859-2 Latin alphabet No. 2
        case 5: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin3);	        // 000005	ISO/IEC 8859-3 Latin alphabet No. 3
        case 6: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin4);	        // 000006	ISO/IEC 8859-4 Latin alphabet No. 4
        case 7: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinCyrillic);	// 000007	ISO/IEC 8859-5 Latin/Cyrillic alphabet
        case 8: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinArabic);	    // 000008	ISO/IEC 8859-6 Latin/Arabic alphabet
        case 9: return 	CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinGreek);	    // 000009	ISO/IEC 8859-7 Latin/Greek alphabet
        case 10: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinHebrew);  	// 000010	ISO/IEC 8859-8 Latin/Hebrew alphabet
        case 11: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin5);	        // 000011	ISO/IEC 8859-9 Latin alphabet No. 5
        case 12: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin6);	        // 000012	ISO/IEC 8859-10 Latin alphabet No. 6
        case 13: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinThai);	    // 000013	ISO/IEC 8859-11 Latin/Thai alphabet
        case 14: return -1;                  	        // 000014	Reserved
        case 15: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin7);	// 000015	ISO/IEC 8859-13 Latin alphabet No. 7 (Baltic Rim)
        case 16: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin8);	// 000016	ISO/IEC 8859-14 Latin alphabet No. 8 (Celtic)
        case 17: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin9);	// 000017	ISO/IEC 8859-15 Latin alphabet No. 9
        case 18: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin10);	// 000018	ISO/IEC 8859-16 Latin alphabet No. 10
        case 19: return -1;	                            // 000019	Reserved
        case 20: return NSShiftJISStringEncoding;	    // 000020	Shift JIS (JIS X 0208 Annex 1 + JIS X 0201)
        case 21: return NSWindowsCP1250StringEncoding;	// 000021	Windows 1250 Latin 2 (Central Europe)
        case 22: return NSWindowsCP1251StringEncoding;	// 000022	Windows 1251 Cyrillic
        case 23: return NSWindowsCP1252StringEncoding;	// 000023	Windows 1252 Latin 1
        case 24: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic);	// 000024	Windows 1256 Arabic
        case 25: return NSUTF16BigEndianStringEncoding;	// 000025	ISO/IEC 10646 UCS-2 (High order byte first)
        case 26: return NSUTF8StringEncoding;	        // 000026	ISO/IEC 10646 UTF-8
        case 27: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_JP);	        // 000027	ISO/IEC 646:1991 International Reference Version of ISO 7-bit coded character set
        case 28: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_E);	        // 000028	Big 5 (Taiwan) Chinese Character Set
        case 29: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);	    // 000029	GB (PRC) Chinese Character Set
        case 30: return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSKorean);	    // 000030	Korean Character Set
        case 899: return NSUTF8StringEncoding;	        // 000899	8-bit binary data
        default: return -1;
    }
    return -1;
}

// Find ASCII ECI marker ("\NNNNNN") in data string
+(NSUInteger) firstECIMarkerIn:(NSData*)data from:(NSUInteger)pos value:(NSUInteger*)val{
    int L = (int)[data length];
    char *str = (char*)[data bytes];
    if (L>6) {
        while (pos<L-6) {
            if ( str[pos]=='\\' ) {
                if ( (str[pos+1]>=48) && (str[pos+1]<58) &&
                    (str[pos+2]>=48) && (str[pos+2]<58) &&
                    (str[pos+3]>=48) && (str[pos+3]<58) &&
                    (str[pos+4]>=48) && (str[pos+4]<58) &&
                    (str[pos+5]>=48) && (str[pos+5]<58) &&
                    (str[pos+6]>=48) && (str[pos+6]<58) ) {
                    if (val) *val = (str[pos+1]-48)*100000 + (str[pos+2]-48)*10000 + (str[pos+3]-48)*1000 + (str[pos+4]-48)*100 + (str[pos+5]-48)*10 + (str[pos+6]-48)*1;
                    return pos;
                }
            }
            pos++;
        }
    }
    return NSUIntegerMax; // not found
}

// Convert data to NSString, using supplied encoding, or try guessing (errors will occur!)
+(NSString*) stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
    NSString* s= [[NSString alloc] initWithData:data encoding:encoding];
    if (s) return s;
    s= [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
    if (s) return s;
    s= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (s) return s;
    s= [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    if (s) return s;
    s= [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return s;
}

// Convert data to NSString, using UTF8 default encoding if needed (errors will occur!)
+(NSString*) stringWithQRData:(NSData*)data mode:(int)qrMode {
    NSStringEncoding encoding = NSUTF8StringEncoding; // UTF8 by default - should depend on locale
    if (qrMode & kVSQRKanjiMode) encoding = NSShiftJISStringEncoding;
    
    // Strip final null byte if any
    if ((((char *)[data bytes])[ [data length]-1 ])==0) {
        data = [NSData	dataWithBytes:[data bytes] length:[data length]-1 ];
    }
    
    NSMutableString* ret = [NSMutableString stringWithCapacity:[data length]];
    NSUInteger pos = 0;
    
    // drop "]Q3" .. "]Q6" header if any (FNC1 and ECI)
    if ( ([data length]>3) &&
        ( !strncmp([data bytes], "]Q3", 3) || !strncmp([data bytes], "]Q4", 3) ) ) pos += 3;
    else if ( ([data length]>5) &&  // Drop the 2-digit FNC1 Application ID too
             ( !strncmp([data bytes], "]Q5", 3) || !strncmp([data bytes], "]Q6", 3) ) ) pos += 5;
    
    // Interpret "\NNNNNN" ECI markers if any
    NSUInteger nextMarker;
    NSUInteger eci = 0;
    do {
        nextMarker = [self firstECIMarkerIn:data from:pos value:&eci];
        // decode segment until next marker or end
        NSString* next = [self stringWithData:[data subdataWithRange:NSMakeRange(pos, MIN(nextMarker, [data length])-pos)] encoding:encoding];
        if (next) {
            [ret appendString:next ];
        }
        if (nextMarker != NSUIntegerMax) {
            pos = nextMarker + 7;
            encoding = [self stringEncodingForECI:(int)eci];
            if (encoding==-1) encoding = [self stringEncodingForECI:0]; // ECI not found
//            NSLog(@"eci: %lu encoding: %lu pos: %lu", (unsigned long)eci, (unsigned long)encoding, (unsigned long)pos);
        }
    } while ( (nextMarker != NSUIntegerMax) && (pos<[data length]) );
    
    return ret;
}

// Convert data to NSString, using specified default encoding if needed (errors will occur!)
+(NSString*) stringWithECIData:(NSData*)data mode:(NSInteger)qrMode encoding:(NSStringEncoding)defaultEncoding {
    if (qrMode & kVSQRKanjiMode) defaultEncoding = NSShiftJISStringEncoding;
    NSStringEncoding encoding = defaultEncoding;
    
    // Strip final null byte if any
    if ((((char *)[data bytes])[ [data length]-1 ])==0) {
        data = [NSData    dataWithBytes:[data bytes] length:[data length]-1 ];
    }
    
    NSMutableString* ret = [NSMutableString stringWithCapacity:[data length]];
    NSUInteger pos = 0;
        
    // Interpret "\NNNNNN" ECI markers if any
    NSUInteger nextMarker;
    NSUInteger eci = 0;
    do {
        nextMarker = [self firstECIMarkerIn:data from:pos value:&eci];
        // decode segment until next marker or end
        NSString* next = [self stringWithData:[data subdataWithRange:NSMakeRange(pos, MIN(nextMarker, [data length])-pos)] encoding:encoding];
        if (next) {
            [ret appendString:next ];
        }
        if (nextMarker != NSUIntegerMax) {
            pos = nextMarker + 7;
            encoding = [self stringEncodingForECI:(int)eci];
            if (encoding==-1) encoding = defaultEncoding; // ECI not found
//            NSLog(@"eci: %lu encoding: %lu pos: %lu", (unsigned long)eci, (unsigned long)encoding, (unsigned long)pos);
        }
    } while ( (nextMarker != NSUIntegerMax) && (pos<[data length]) );
    
    return ret;
}

@end
