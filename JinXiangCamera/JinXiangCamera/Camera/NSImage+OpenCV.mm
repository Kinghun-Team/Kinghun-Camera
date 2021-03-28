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

- (NSImage*)imageToGrayImage:(NSImage*)image {
    // 1.将iOS的UIImage转成cv::Mat
    cv::Mat mat_image = [self cvMatFromUIImage:image];
    // 2. 将cv::Mat转成更改后的UIImage
    NSImage * img = [self UIImageFromCVMat:mat_image];
    return img;
}

//UIImage To cv::Mat:
- (cv::Mat)cvMatFromUIImage:(NSImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//cv::Mat To UIImage:
-(NSImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
//    if (cvMat.elemSize() == 1) {//可以根据这个决定使用哪种
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    } else {
//        colorSpace = CGColorSpaceCreateDeviceRGB();
//    }
    
    colorSpace = CGColorSpaceCreateDeviceGray();

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
//    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    NSImage *finalImage = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeMake(cvMat.cols, cvMat.rows)];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
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
