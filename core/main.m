#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:path]);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
    }
    
    CFRelease(destination);
    CFRelease(url);
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NSFileManager* manager = [NSFileManager defaultManager];
        NSArray* dirEnum = [manager subpathsAtPath:@"."];

        for (NSUInteger i=0, l=dirEnum.count; i<l; i++) {
            NSString* file = [dirEnum objectAtIndex:i];
            if ([[file pathExtension] isEqualToString:@"png"]) {
                CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:file]);
                CGImageSourceRef ref = CGImageSourceCreateWithURL(url, NULL);
                CGImageRef myImage = CGImageSourceCreateImageAtIndex(ref, 0, NULL);
                
                size_t imageWidth = CGImageGetWidth(myImage);
                size_t imageHeight = CGImageGetHeight(myImage);
                int cropSize = -1;
                
                if (imageWidth==320 && imageHeight==480) {
                    cropSize = 20;
                } else if (imageWidth==640 && imageHeight==960) {
                    cropSize = 40;
                } else if (imageWidth==640 && imageHeight==1136) {
                    cropSize = 40;
                } else if (imageWidth==768 && imageHeight==1024) {
                    cropSize = 20;
                } else if (imageWidth==1536 && imageHeight==1536) {
                    cropSize = 40; // iPad Retina
                }
                
                if (cropSize>0) {
                    CGRect crop = CGRectMake(0, cropSize, imageWidth, imageHeight-cropSize);
                    CGImageRef src = CGImageCreateWithImageInRect(myImage, crop);
                    
                    NSString* destinationFile = [NSString stringWithFormat:@"%@%@", [file substringToIndex:file.length-3], @"jpeg"];
                    NSLog(@"Writing %@", destinationFile);
                    
                    CGImageWriteToFile(src, destinationFile);
                    CFRelease(src);
                }
                CFRelease(myImage);
                CFRelease(ref);
                CFRelease(url);
                
            }
        }
    }
    return 0;
}

