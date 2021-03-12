//
//  CameraManager.m
//  金翔影像
//
//  Created by Apple on 2020/12/4.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>
#pragma clang diagnostic pop
#import "CameraManager.h"

#define cameraManager   [CameraManager sharedManager]

typedef void(^GetImage)(NSImage *iamge);
@interface CameraManager()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    GetImage getImage;
}

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;
//输出视频流
@property (nonatomic ,strong) AVCaptureVideoDataOutput *videoDataOutput;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;
/** 输出刷新线程 */
@property (nonatomic,strong) dispatch_queue_t videoDataOutputQueue;
//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic,assign) CGFloat imageWidth;//图片高度  图片比例9：16
@property(nonatomic,assign)BOOL getPhoto;//获取图片

@end

@implementation CameraManager

+ (NSArray *)cameraDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *devList = @[@"UVC Camera VendorID_3141 ProductID_5634"];//摄像头id
    
    NSMutableArray *cameraList = [NSMutableArray array];
    for (AVCaptureDevice *dev in devices) {
        if ([devList containsObject:dev.modelID]) {
            [cameraList addObject:dev];
        }
    }
    if (cameraManager.allCamera == YES) {
        return devices;
    } else {
        return cameraList;
    }
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureStillImageOutput *)imageOutput {
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _imageOutput;
}

+ (instancetype)sharedManager {
    static CameraManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CameraManager alloc] init];
        sharedManager.imageType = IMGPNG;
        sharedManager.imageSize = imageSize1920;
    });
    return sharedManager;
}

+ (void)cameraDefaultConfig {
    NSArray *arr = [CameraManager cameraDevice];
    if (arr.count == 0) {
        return;
    }
    [cameraManager setAVCapture:arr.firstObject];
}

+ (void)setImageSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    [cameraManager.session beginConfiguration];
    cameraManager.session.sessionPreset = sessionPreset;
    [cameraManager.session commitConfiguration];
}

- (void)setAVCapture:(AVCaptureDevice *)device{
    self.device = device;
    
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    //    AVCaptureSessionPreset1280x720
    //    AVCaptureSessionPreset1920x1080
    //    AVCaptureSessionPreset3840x2160
    [CameraManager setImageSessionPreset:AVCaptureSessionPresetPhoto];
    
#define FYFVideoDataOutputQueue "VideoDataOutputQueue"
    self.videoDataOutputQueue = dispatch_queue_create(FYFVideoDataOutputQueue, DISPATCH_QUEUE_SERIAL);
    // 5.输出流(从指定的视频中采集数据)
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    //   设置采集相片的像素格式
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    //   处理输出线程被阻塞时，丢弃掉没有处理的画面
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
//    camera.setDisplayOrientation(0);
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    
//    for (AVCaptureConnection * av in self.videoDataOutput.connections) {
//        if (av.supportsVideoMirroring) {
//            //镜像设置
//            av.videoMirrored = YES;
//        }
//    }
}


- (void)start {
    if (self.device == nil) {
        [CameraManager cameraDefaultConfig];
    }
    //设备取景开始
    [self.session startRunning];
}

- (void)stop {
    if (self.device != nil) {
        for(AVCaptureInput *input in self.session.inputs){
            [self.session removeInput:input];
        }
        for(AVCaptureOutput *output in self.session.outputs){
            [self.session removeOutput:output];
        }
        self.videoDataOutput = nil;
        self.videoDataOutputQueue = nil;
        self.device = nil;
        self.input = nil;
    }
    [self.session stopRunning];
}

- (void)setNewAVCapture:(AVCaptureDevice *)device{
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    
    AVCaptureDeviceInput *newInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    if ([self.session canAddInput:newInput]) {
        [self.session addInput:newInput];
        self.input = newInput;
    } else {
        // 防止 newInput 不可用
        [self.session addInput:self.input];
    }
    [self.session commitConfiguration];
}

#pragma mark  AVCaptureVideoDataOutputSampleBufferDelegate 视频流
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//    });
    NSImage *iamge = [self convertSameBufferToNSImage:sampleBuffer];
    
//    image = [[UIImage alloc]initWithCGImage:image.CGImage scale:1.0f orientation:imgOrientation];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(cameraBufferIamge:)]) {
            [self.delegate cameraBufferIamge:iamge];
        }
    });
    if (self.getPhoto == YES) {//获取帧
        self.getPhoto = NO;
        getImage(iamge);
        [self saveImage:iamge];
    }
}

- (NSImage *)convertSameBufferToNSImage:(CMSampleBufferRef)sampleBuffer {
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
    
    switch (self.imageSize) {
        case imageSize1920:
            self.imageWidth = 1080.0/2;
            break;
        case imageSize2560:
            self.imageWidth = 1440.0/2;
            break;
        case imageSize3840:
            self.imageWidth = 2160.0/2;
            break;
        case imageSize4480:
            self.imageWidth = 2520.0/2;
            break;
        default:
            break;
    }
    // 用Quartz image创建一个UIImage对象image
    NSImage *image = [[NSImage alloc] initWithCGImage:quartzImage size:NSMakeSize(self.imageWidth*16.0/9.0, self.imageWidth)];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}

- (NSImage *)mirrorImage:(NSImage *)originImage{
//    CGRect rect = CGRectMake(0, 0, originImage.size.width , originImage.size.height);
//    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
//    CGContextRef currentContext =  UIGraphicsGetCurrentContext();
//    CGContextClipToRect(currentContext, rect);
//    CGContextRotateCTM(currentContext, M_PI);
//    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
//    CGContextDrawImage(currentContext, rect, originImage.CGImage);
//    UIImage* drawImage =  UIGraphicsGetImageFromCurrentImageContext();
//    return [UIImage imageWithCGImage:drawImage.CGImage scale:originImage.scale orientation:originImage.imageOrientation];
//    [[NSImage alloc] initWithDataIgnoringOrientation:originImage];
    return originImage;
}

- (void)photoSetImage:(NSImageView *)imageView {
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion) {
        NSLog(@"拍照失败!");
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
        if (imageDataSampleBuffer == nil) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//        [imageData writeToFile:[@"~/Documents/photoTest.png" stringByExpandingTildeInPath] atomically:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [[NSImage alloc] initWithData:imageData];
//            [self saveImage:imageView.image];
        });
    }];
}

#pragma - 保存图片
- (void)saveImage:(NSImage *)image {
    [image lockFocus];
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:NSImageCompressionFactor];
    
    //之后 转化为NSData 以便存到文件中
    NSBitmapImageFileType imageType = NSPNGFileType;
    NSString *fileString = @"png";
    switch (self.imageType) {
        case IMGPNG:
            imageType = NSPNGFileType;
            fileString = @"png";
            break;
        case IMGJPG:
            imageType = NSBitmapImageFileTypeJPEG;
            fileString = @"jpg";
            break;
        case IMGTIF:
            imageType = NSBitmapImageFileTypeTIFF;
            fileString = @"TIF";
            break;
        case IMGBMP:
            imageType = NSBitmapImageFileTypeBMP;
            fileString = @"BMP";
            break;
        default:
            break;
    }
    
    NSData *imageData = [bits representationUsingType:imageType properties:imageProps];
    //设定好文件路径后进行存储就ok了
    BOOL isSuccess = [imageData writeToFile:[[NSString stringWithFormat:@"~/Documents/photoTest.%@",fileString] stringByExpandingTildeInPath] atomically:YES];
    //保存的文件路径一定要是绝对路径，相对路径不行
    NSLog(@"Save Image: %d", isSuccess);
}

- (void)getPhotoImage:(void(^)(NSImage *image))successImage {
    self.getPhoto = YES;
    getImage = ^(NSImage *iamge) {
        successImage(iamge);
    };
}

@end
