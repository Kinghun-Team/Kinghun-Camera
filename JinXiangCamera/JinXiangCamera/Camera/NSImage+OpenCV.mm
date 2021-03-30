//
//  NSImage+OpenCV.m
//  金翔影像
//
//  Created by Apple on 2020/12/26.
//

#import "NSImage+OpenCV.h"

static void ProviderReleaseDataNOP(void *info, const void *data, size_t size)
{
    return;
}

@implementation NSImage (OpenCV)

#pragma mark - 灰度处理
+ (NSImage *)systemImageToGrayImage:(NSImage *)image{
    int width  = image.size.width;
    int height = image.size.height;
    //第一步：创建颜色空间(说白了就是开辟一块颜色内存空间)
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    //第二步：颜色空间上下文(保存图像数据信息)
    //参数一：指向这块内存区域的地址（内存地址）
    //参数二：要开辟的内存的大小，图片宽
    //参数三：图片高
    //参数四：像素位数(颜色空间，例如：32位像素格式和RGB的颜色空间，8位）
    //参数五：图片的每一行占用的内存的比特数
    //参数六：颜色空间
    //参数七：图片是否包含A通道（ARGB四个通道）
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, kCGImageAlphaNone);
    if (context == nil) {
        return  nil;
    }
    //渲染图片
    //参数一：上下文对象
    //参数二：渲染区域
    //源图片
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    //将绘制的颜色空间转成CGImage
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    //释放内存
    CGColorSpaceRelease(colorRef);
    //将c/c++图片转成iOS可显示的图片
//    NSImage *dstImage = [[NSImage alloc] imageWithCGImage:grayImageRef];
    NSImage *dstImage = [[NSImage alloc] initWithCGImage:grayImageRef size:NSMakeSize(width, height)];
    //释放内存
    CGImageRelease(grayImageRef);
    return dstImage;
}

+ (NSImage *)colorSameBufferImage:(CMSampleBufferRef)sampleBuffer withSize:(NSSize)size {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    NSImage *image = [[NSImage alloc] initWithCGImage:quartzImage size:size];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return image;
}

+ (NSImage *)graySameBufferImage:(CMSampleBufferRef)sampleBuffer withSize:(NSSize)size {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaNone);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    NSImage *image = [[NSImage alloc] initWithCGImage:quartzImage size:size];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return image;
}


-(CGImageRef)CGImage {
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   [self size].width,
                                                   [self size].height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    
    return cgImage;
}


-(cv::Mat)CVMat {
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return cvMat;
}

- (cv::Mat)CVGrayscaleMat {
    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    cv::Mat cvMat = cv::Mat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return cvMat;
}

+ (NSImage *)imageWithCVMat:(const cv::Mat&)cvMat {
//    return [[[NSImage alloc] initWithCVMat:cvMat] autorelease];
    return [[NSImage alloc] initWithCVMat:cvMat];
}

-(id)initWithCVMat:(const cv::Mat&)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return image;
}

@end
