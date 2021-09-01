//
//  NSImage+OpenCV.m
//  金翔影像
//
//  Created by Apple on 2020/12/26.
//

#import "NSImage+OpenCV.h"
#import <opencv2/highgui/highgui_c.h>

static void ProviderReleaseDataNOP(void *info, const void *data, size_t size)
{
    return;
}

//double  minThreshold = 10;
//double  ratioThreshold = 3;

@implementation NSImage (OpenCV)

#pragma mark - NSImge灰度处理
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
    
    context = [self applyTransform:abs([CameraManager sharedManager].rotate) toContextRef:context withSize:CGSizeMake(width, height)];
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
    
    context = [self applyTransform:abs([CameraManager sharedManager].rotate) toContextRef:context withSize:CGSizeMake(width, height)];
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

/**
 二值化
 */
+ (NSImage *)covertToGrayScaleImage:(CMSampleBufferRef)sampleBuffer withSize:(NSSize)size {
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
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    
    //像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    //清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));
    
    CGContextRef BWcontext = CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(BWcontext, CGRectMake(0, 0, width, height), quartzImage);
    CGImageRelease(quartzImage);
    
    int tt = 1;
    CGFloat intensity;
    int bw;
    for (int y = 0; y <height; y++) {
        for (int x =0; x <width; x ++) {
            uint8_t *rgbaPixel = (uint8_t *)&pixels[y*width+x];
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            
            bw = intensity > 0.45?255:0;
            
            rgbaPixel[tt] = bw;
            rgbaPixel[tt + 1] = bw;
            rgbaPixel[tt + 2] = bw;
        }
    }
    
    BWcontext = [self applyTransform:abs([CameraManager sharedManager].rotate) toContextRef:BWcontext withSize:CGSizeMake(width, height)];
    
    CGImageRef image = CGBitmapContextCreateImage(BWcontext);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(BWcontext);
    CGColorSpaceRelease(colorSpace);
    
    free(pixels);
    // make a new UIImage to return
    NSImage *resultUIImage = [[NSImage alloc] initWithCGImage:image size:size];
    // we're done with image now too
    CGImageRelease(image);
    return resultUIImage;
}

/**
 NSImage二值化
 */
- (NSImage *)covertToGrayScale{
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    //像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    //清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用 pixels 创建一个 context
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    int tt = 1;
    CGFloat intensity;
    int bw;
    
    for (int y = 0; y <height; y++) {
        for (int x =0; x <width; x ++) {
            uint8_t *rgbaPixel = (uint8_t *)&pixels[y*width+x];
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            
            bw = intensity > 0.45?255:0;
            
            rgbaPixel[tt] = bw;
            rgbaPixel[tt + 1] = bw;
            rgbaPixel[tt + 2] = bw;
        }
    }
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    // make a new UIImage to return
    NSImage *resultUIImage = [[NSImage alloc] initWithCGImage:quartzImage size:size];
    // we're done with image now too
    CGImageRelease(quartzImage);
    return resultUIImage;
}

- (NSImage *)turnUpsideDownAndMirrorRotate:(NSInteger)rotate {
    NSSize srcSize = [self size];
    float srcw = srcSize.width;
    float srch = srcSize.height;
    if((!self) || srcw == 0 || srch == 0) {
        return nil;
    }
    float rotateDeg = (float)(rotate % 360);
    NSRect rotateRect = NSMakeRect(0, 0, srcw, srch);
    if (rotateDeg == 90.0 || rotateDeg == 270.0) {
        rotateRect = NSMakeRect(0, 0, srch, srcw);
    }
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:rotateRect.size];
    
    [rotatedImage lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    //方法一：180度旋转
    [transform translateXBy:(0.5 * srcw) yBy: (0.5 * srch)];  //将坐标系原点移至图片中心点
    [transform rotateByDegrees:rotateDeg];//以图片中心为原点，旋转传入的度数
    [transform translateXBy:(-0.5 * srcw) yBy: (-0.5 * srch)]; //将坐标系回复原状
    //水平镜像反转
    [transform scaleXBy:-1.0 yBy:1.0];
    [transform translateXBy:-srcw yBy:0];
    //方法二：竖直镜像反转
    //    [transform scaleXBy:1.0 yBy:-1.0];
    //    [transform translateXBy:0 yBy:-srch];
    [transform concat];
    [self drawInRect:rotateRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [rotatedImage unlockFocus];
    return rotatedImage;
}

//+ (CGImageRef)applyTransform:(CGAffineTransform)transform toImageRef:(CGImageRef)imageref {
//    size_t width = CGImageGetWidth(imageref);
//    size_t height = CGImageGetHeight(imageref);
//    CGSize newSize = CGRectApplyAffineTransform(CGRectMake(0, 0, width, height), transform).size;
//    CGContextRef ctx = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
//                                             CGImageGetBitsPerComponent(imageref), 0,
//                                             CGImageGetColorSpace(imageref),
//                                             CGImageGetBitmapInfo(imageref));
//    CGContextConcatCTM(ctx, transform);
//    CGRect rotatedDrawRect = CGRectZero;
//    if (transform.a >= 0 && transform.b >= 0) {
//        rotatedDrawRect = CGRectMake(transform.b * height * transform.a, - transform.b * transform.b * height, width, height);
//    }else if (transform.a <= 0 && transform.b >= 0) {
//        rotatedDrawRect = CGRectMake(- fabs(powf(transform.a, 2) * width), - fabs(transform.a * transform.b * width) - height, width, height);
//    }else if (transform.a <= 0 && transform.b <= 0){
//        rotatedDrawRect = CGRectMake(- fabs(width + height * fabs(transform.a * transform.b)), - fabs(height * powf(transform.a, 2)), width, height);
//    }else if (transform.a >= 0 && transform.b <= 0){
//        rotatedDrawRect = CGRectMake(- fabs(powf(transform.b, 2) * width), fabs(transform.a * transform.b * width), width, height);
//    }
//    CGContextDrawImage(ctx, rotatedDrawRect, imageref);
//    CGImageRef resultRef = CGBitmapContextCreateImage(ctx);
//    CGContextRelease(ctx);
//    return resultRef;
//}

//@property (nonatomic, strong) CIContext* ciContext;
//- (void)dealWithSampleBuffer:(CMSampleBufferRef)buffer {
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
//
//    CIImage *ciimage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
//    size_t width                        = CVPixelBufferGetWidth(pixelBuffer);
//    size_t height                       = CVPixelBufferGetHeight(pixelBuffer);
//   // 旋转的方法
//    CIImage *wImage = [ciimage imageByApplyingCGOrientation:kCGImagePropertyOrientationLeft];
//
//    CIImage *newImage = [wImage imageByApplyingTransform:CGAffineTransformMakeScale(0.5, 0.5)];
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    CVPixelBufferRef newPixcelBuffer = nil;
//    CVPixelBufferCreate(kCFAllocatorDefault, height * 0.5, width * 0.5, kCVPixelFormatType_32BGRA, nil, &newPixcelBuffer);
//    [_ciContext render:newImage toCVPixelBuffer:newPixcelBuffer];
//
//
//    //
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//    CMVideoFormatDescriptionRef videoInfo = nil;
//    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, newPixcelBuffer, &videoInfo);
//    CMTime duration = CMSampleBufferGetDuration(buffer);
//    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(buffer);
//    CMTime decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(buffer);
//    CMSampleTimingInfo sampleTimingInfo;
//    sampleTimingInfo.duration = duration;
//    sampleTimingInfo.presentationTimeStamp = presentationTimeStamp;
//    sampleTimingInfo.decodeTimeStamp = decodeTimeStamp;
//    //
//    CMSampleBufferRef newSampleBuffer = nil;
//    CMSampleBufferCreateForImageBuffer(kCFAllocatorMalloc, newPixcelBuffer, true, nil, nil, videoInfo, &sampleTimingInfo, &newSampleBuffer);
//
//   // 对新buffer做处理
//
//    // release
//    CVPixelBufferRelease(newPixcelBuffer);
//    CFRelease(newSampleBuffer);
//}

+ (CGContextRef)applyTransform:(NSInteger)rotate toContextRef:(CGContextRef)contextRef withSize:(CGSize)size {
    NSInteger i = -rotate;
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2 * i);
    size_t width = size.width;
    size_t height = size.height;
    CGContextConcatCTM(contextRef, transform);
    CGRect rotatedDrawRect = CGRectZero;
    if (transform.a >= 0 && transform.b >= 0) {
        rotatedDrawRect = CGRectMake(transform.b * height * transform.a, - transform.b * transform.b * height, width, height);
    }else if (transform.a <= 0 && transform.b >= 0) {
        width = size.height;
        height = size.width;
        rotatedDrawRect = CGRectMake(- fabs(powf(transform.a, 2) * width), - fabs(transform.a * transform.b * width) - height, width, height);
    }else if (transform.a <= 0 && transform.b <= 0){
        rotatedDrawRect = CGRectMake(- fabs(width + height * fabs(transform.a * transform.b)), - fabs(height * powf(transform.a, 2)), width, height);
    }else if (transform.a >= 0 && transform.b <= 0){
        width = size.height;
        height = size.width;
        rotatedDrawRect = CGRectMake(- fabs(powf(transform.b, 2) * width), fabs(transform.a * transform.b * width), width, height);
    }
    CGImageRef quartzImage = CGBitmapContextCreateImage(contextRef);
    CGContextDrawImage(contextRef, rotatedDrawRect, quartzImage);
    CGImageRelease(quartzImage);
    return contextRef;
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

- (id)initWithCVMat:(const cv::Mat&)cvMat {
    @autoreleasepool {
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
}

+ (NSImage *)getSubImageFrom:(NSImage *)imageToCrop withRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
//    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    NSImage *cropped = [[NSImage alloc] initWithCGImage:imageRef size:rect.size];
    CGImageRelease(imageRef);
    return cropped;
}

//+ (CGPoint)edgeDetectionToImage:(NSImage *)image {
//    cv::Mat sourceMatImage = image.CVMat;
//    // 降噪
//    blur(sourceMatImage, sourceMatImage, cv::Size(3,3));
//    // 转为灰度图
//    cvtColor(sourceMatImage, sourceMatImage, CV_BGR2GRAY);
//    // 二值化
//    threshold(sourceMatImage, sourceMatImage, 190, 255, CV_THRESH_BINARY);
//    // 检测边界
//    Canny(sourceMatImage, sourceMatImage, minThreshold * ratioThreshold, minThreshold);
//    // 获取轮廓
//    std::vector<std::vector<cv::Point>> contours;
//    findContours(sourceMatImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
//
//    // 求所有形状的最小外接矩形中最大的一个
//    cv::RotatedRect box;
//    for( int i = 0; i < contours.size(); i++ ){
//        cv::RotatedRect rect = cv::minAreaRect( cv::Mat(contours[i]) );
//        if (box.size.width < rect.size.width) {
//            box = rect;
//        }
//    }
//    CGPoint imageCenter = CGPointMake(box.center.x, box.center.y);
//    {
//        // 画出来矩形和4个点, 供调试。此部分代码可以不要
//        cv::Mat drawing = cv::Mat::zeros(sourceMatImage.rows, sourceMatImage.cols, CV_8UC3);
//        cv::Scalar color = cv::Scalar( rand() & 255, rand() & 255, rand() & 255 );
//        cv::Point2f rect_points[4];
//        box.points( rect_points );
//        for ( int j = 0; j < 4; j++ )
//        {
//            line(drawing, rect_points[j], rect_points[(j+1)%4], color);
//            circle(drawing, rect_points[j], 10, color, 2);
//        }
//    //        return MatToUIImage(drawing);
//    }
//    return imageCenter;
//
////    /*
////     *  重新绘制轮廓
////     */
////    // 初始化一个8UC3的纯黑图像
////    Mat dstImg(sourceMatImage.size(), CV_8UC3, Scalar::all(0));
////    // 用于存放轮廓折线点集
////    std::vector<std::vector<cv::Point>> contours_poly(contours.size());
////    // STL遍历
////    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
////    std::vector<std::vector<cv::Point>>::const_iterator itContourEnd = contours.end();
////    // ++i 比 i++ 少一次内存写入,性能更高
////    for (int i=0 ; itContours != itContourEnd; ++itContours,++i) {
////        approxPolyDP(Mat(contours[i]), contours_poly[i], 15, true);
////        // 绘制处理后的轮廓,可以一段一段绘制,也可以一次性绘制
////        // drawContours(dstImg, contours_poly, i, Scalar(208, 19, 29), 8, 8);
////    }
////
////    /*如果C++ 基础不够,可以使用 for 循环
////     *    for (int i = 0; i < contours.size(); i ++) {
////     *        approxPolyDP(contours[i] , contours_poly[i], 5, YES);
////     *    }
////     */
////
////    // 绘制处理后的轮廓,一次性绘制
////    drawContours(dstImg, contours_poly, -1, Scalar(208, 19, 29), 8, 8);
////    // 显示绘制结果
////    self.desImageView.image = MatToUIImage(dstImg);
//}

@end
