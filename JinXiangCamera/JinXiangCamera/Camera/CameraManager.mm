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

@property (nonatomic,assign) CGFloat iamgeHeight;//图片高度  图片比例9：16
@property(nonatomic,assign)BOOL getPhoto;//获取图片

@end

@implementation CameraManager

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
    });
    return sharedManager;
}

+ (void)cameraDefaultConfig {
    [cameraManager setAVCapture:[cameraManager cameraWithPosition:AVCaptureDevicePositionFront]];
}

+ (void)setImageSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    [cameraManager.session beginConfiguration];
    cameraManager.session.sessionPreset = sessionPreset;
    [cameraManager.session commitConfiguration];
}

- (void)setAVCapture:(AVCaptureDevice *)device{
    self.device = device;
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    //     拿到的图像的大小可以自行设定
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
}

- (void)start {
    //预览层的生成
//    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    self.previewLayer.frame = view.bounds;
//    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////    [[self.previewLayer connection] setVideoOrientation:(AVCaptureVideoOrientationPortrait)];
//    [view.layer insertSublayer:self.previewLayer above:0];
    
//    if ([self.device lockForConfiguration:nil]) {
//        //自动闪光灯，
//        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
//            [self.device setFlashMode:AVCaptureFlashModeAuto];
//        }
//        //自动白平衡,但是好像一直都进不去
//        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
//            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
//        }
//        [self.device unlockForConfiguration];
//    }
    
//    NSError *error;
//    if ([self.device lockForConfiguration:&error]) {
//        [self.device setFocusPointOfInterest:CGPointMake(view.frame.origin.x + view.frame.size.width/2, view.frame.origin.y + view.frame.size.height/2)];AVCaptureFocusModeContinuousAutoFocus
//        self.device.focusMode = AVCaptureFocusModeAutoFocus;
//        [self.device unlockForConfiguration];
//    }
//    else{
//        NSLog(@"%@",error);
//    }
    
    //设备取景开始
    [self.session startRunning];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return devices.lastObject;
}

#pragma mark  AVCaptureVideoDataOutputSampleBufferDelegate 视频流
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//    });
    NSImage *iamge = [self convertSameBufferToNSImage:sampleBuffer];
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

- (NSImage *)convertSameBufferToNSImage:(CMSampleBufferRef)sampleBuffer
{
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
    
    switch (self.iamgeSize) {
        case ImageSize1080:
            self.iamgeHeight = 1080.0/2;
            break;
        case ImageSize1960:
            self.iamgeHeight = 1960.0/2;
            break;
        case ImageSize2560:
            self.iamgeHeight = 2560.0/2;
            break;
        case ImageSize3860:
            self.iamgeHeight = 3860.0/2;
            break;
        default:
            self.iamgeHeight = 1080.0/2;
            break;
    }
    // 用Quartz image创建一个UIImage对象image
    NSImage *image = [[NSImage alloc] initWithCGImage:quartzImage size:NSMakeSize(self.iamgeHeight*16.0/9.0, self.iamgeHeight)];
//    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
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
    NSData *imageData = [bits representationUsingType:NSPNGFileType properties:imageProps];
    
    //设定好文件路径后进行存储就ok了
    BOOL isSuccess = [imageData writeToFile:[@"~/Documents/photoTest.png" stringByExpandingTildeInPath] atomically:YES];
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
