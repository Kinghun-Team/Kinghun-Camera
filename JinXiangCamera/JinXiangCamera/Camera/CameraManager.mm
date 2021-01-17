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

using namespace cv;
using namespace std;

@interface CameraManager()
{
    NSViewController *delegate;
    NSImageView * cameraimageView;
    NSImageView * processimageView;
    VideoCapture cap;
    cv::Mat gtpl;
    int cameraIndex;
    NSTimer *timer;
}

#define cameraManager   [CameraManager sharedManager]

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;



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
    //    AVCaptureDevicePositionBack  后置摄像头
    //    AVCaptureDevicePositionFront 前置摄像头
    [cameraManager cameraDefaultConfig:[cameraManager cameraWithPosition:AVCaptureDevicePositionFront]];
}

+ (void)setImageSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    [cameraManager.session beginConfiguration];
    cameraManager.session.sessionPreset = sessionPreset;
    [cameraManager.session commitConfiguration];
}

- (void)cameraDefaultConfig:(AVCaptureDevice *)device{
    self.device = device;
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    //     拿到的图像的大小可以自行设定
    //    AVCaptureSessionPreset320x240
    //    AVCaptureSessionPreset352x288
    //    AVCaptureSessionPreset640x480
    //    AVCaptureSessionPreset960x540
    //    AVCaptureSessionPreset1280x720
    //    AVCaptureSessionPreset1920x1080
    //    AVCaptureSessionPreset3840x2160
    [CameraManager setImageSessionPreset:AVCaptureSessionPresetPhoto];
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
}

- (void)startCameraToView:(NSView *)view {
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer insertSublayer:self.previewLayer above:0];
    //设备取景开始
    [self.session startRunning];
    if ([self.device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.device unlockForConfiguration];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    return devices.lastObject;
//    for ( AVCaptureDevice *device in devices )
//
//        return device;
//        if ( device.position == position ){
            
//        }
    return nil;
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
            [self saveImage:imageView.image];
        });
    }];
}


#pragma - 保存图片
- (void)saveImage:(NSImage *)image
{
    [image lockFocus];
    //先设置 下面一个实例1280x720
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

//AVCaptureFlashMode  闪光灯
//AVCaptureFocusMode  对焦
//AVCaptureExposureMode  曝光
//AVCaptureWhiteBalanceMode  白平衡
//闪光灯和白平衡可以在生成相机时候设置
//曝光要根据对焦点的光线状况而决定,所以和对焦一块写
//point为点击的位置
- (void)focusAtPoint:(CGPoint)point{
//    CGSize size = self.view.bounds.size;
//    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
//    NSError *error;
//    if ([self.device lockForConfiguration:&error]) {
//        //对焦模式和对焦点
//        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//            [self.device setFocusPointOfInterest:focusPoint];
//            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
//        }
//        //曝光模式和曝光点
//        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
//            [self.device setExposurePointOfInterest:focusPoint];
//            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
//        }
//
//        [self.device unlockForConfiguration];
        //设置对焦动画
//        _focusView.center = point;
//        _focusView.hidden = NO;
//        [UIView animateWithDuration:0.3 animations:^{
//            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
//        }completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.5 animations:^{
//                _focusView.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                _focusView.hidden = YES;
//            }];
//        }];
//    }
}




//设置分辨率
- (void)setCameraResolutionByPresetWithHeight:(int)height session:(AVCaptureSession *)session {
    /*
     Note: the method only support your frame rate <= 30 because we must use `activeFormat` when frame rate > 30, the `activeFormat` and `sessionPreset` are exclusive
     */
//    AVCaptureSessionPreset preset = [self getSessionPresetByResolutionHeight:height];
//    if ([session.sessionPreset isEqualToString:preset]) {
//        NSLog(@"Needn't to set camera resolution repeatly !");
//        return;
//    }
//
//    if (![session canSetSessionPreset:preset]) {
//        NSLog(@"Can't set the sessionPreset !");
//        return;
//    }
//
//    [session beginConfiguration];
//    session.sessionPreset = preset;
//    [session commitConfiguration];
}

//设置帧率
- (void)setCameraForLFRWithFrameRate:(int)frameRate {
    // Only for frame rate <= 30
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [captureDevice lockForConfiguration:NULL];
    [captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, frameRate)];
    [captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, frameRate)];
    [captureDevice unlockForConfiguration];
}

//曝光调节
- (void)setExposureWithNewValue:(CGFloat)newExposureValue device:(AVCaptureDevice *)device {
    NSError *error;
    if ([device lockForConfiguration:&error]) {
//        [device setExposureTargetBias:newExposureValue completionHandler:nil];
//        [device setExposureMode:(AVCaptureExposureMode)];
        [device unlockForConfiguration];
    }
}

//自动计算对焦点
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates captureVideoPreviewLayer:(AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [captureVideoPreviewLayer frame].size;
    
    if ([captureVideoPreviewLayer.connection isVideoMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    // Convert UIKit coordinate to Focus Point(0.0~1.1)
    if (@available(macOS 10.15, *)) {
        pointOfInterest = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:viewCoordinates];
    } else {
        
    }
    
    return pointOfInterest;
}

//屏幕填充方式
- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer session:(AVCaptureSession *)session {
    [session beginConfiguration];
    [previewLayer setVideoGravity:videoGravity];
    [session commitConfiguration];
}

//opencv
- (id)initWithController:(NSViewController*)c andCameraImageView:(NSImageView*)iv processImage:(NSImageView *)processIv
{
    delegate = c;
    cameraimageView = iv;
    processimageView = processIv;
    
    cameraIndex = -1;
    timer = [NSTimer timerWithTimeInterval:30/1000.0 target:self selector:@selector(show_camera) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    return self;
}

- (void)processImage:(cv::Mat &)img {
    cv::Mat gimg;
    
    // Convert incoming img to greyscale to match template
    cv::cvtColor(img, gimg, COLOR_BGR2GRAY);
    
    // 5*5滤波
    cv::Mat blurred;
    cv::blur(gimg, blurred, cv::Size(5, 5));
    
    imshow("blurred", blurred);
    
    // 自适应二值化方法
    cv::Mat adaptiveThreshold;
    cv::adaptiveThreshold(blurred, adaptiveThreshold, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 15, 5);
    // canny边缘检测
    cv::Mat edges;
    cv::Canny(adaptiveThreshold, edges, 10, 100);
    // 从边缘图中寻找轮廓
    std::vector<std::vector<cv::Point>> contours;
    findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    
    double maxArea = 0;
    
    vector<cv::Point> approx;
    vector<cv::Point> docCnt;
    vector<cv::Point> maxAreaContour;
    for (size_t i = 0; i < contours.size(); i++)
    {
        double area = contourArea(contours[i]);
        if (area > maxArea) {
            maxArea = area;
            maxAreaContour = contours[i];
        }
    }
    
    // approximate contour with accuracy proportional
    // to the contour perimeter
    approxPolyDP(maxAreaContour, approx, arcLength(maxAreaContour, true)*0.02, true);

    // Note: absolute value of an area is used because
    // area may be positive or negative - in accordance with the
    // contour orientation
    if (approx.size() == 4 &&
            isContourConvex(Mat(approx)))
    {
        docCnt = approx;
        std::vector<std::vector<cv::Point>> showContours(1);
        showContours[0] = docCnt;
        drawContours(img, showContours, -1, Scalar(208, 19, 29), 2);
    }
}

- (void)start
{
    [self openCamera];
}

- (void)stop
{
//    videoCap.close();
}

- (void)openCamera {
    VideoCapture capture = VideoCapture(0);
    if (capture.isOpened()) {
        self->cap = capture;
        self->cameraIndex = 0;
    } else {
        VideoCapture capture_usb = VideoCapture(1);
        if (capture_usb.isOpened()) {
            self->cap = capture_usb;
            self->cameraIndex = 1;
        } else {
            printf("未找到摄像头,请检查设备连接");
            return;
        }
    }
    
    self->cap.set(3, 1400);
    self->cap.set(4, 1050);
    
    [self->timer setFireDate:[NSDate distantPast]];
;
    
}

- (void)show_camera {
    if (self->cap.isOpened()) {
        Mat frame;
        self->cap.read(frame);
        NSImage *image = MatToNSImage(frame);
        self->cameraimageView.image = image;
        
        // processImage
        Mat processFrame = frame.clone();
        [self processImage:processFrame];
        NSImage *processimage = MatToNSImage(processFrame);
        self->processimageView.image = processimage;
    }
//    if (self.recongnitioned) {
//        self.recognition()
//    }
}

/// Converts an NSImage to Mat.
static void NSImageToMat(NSImage *image, cv::Mat &mat) {
    // Create a pixel buffer.
    NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
    NSInteger width = bitmapImageRep.pixelsWide;
    NSInteger height = bitmapImageRep.pixelsHigh;
    CGImageRef imageRef = bitmapImageRep.CGImage;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);

    // Draw all pixels to the buffer.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);
    
    mat = mat8uc3;
}

/// Converts a Mat to NSImage.
static NSImage *MatToNSImage(cv::Mat &mat) {
    // Create a pixel buffer.
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
    }

    // Change a image format.
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [NSImage new];
    [image addRepresentation:bitmapImageRep];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return image;
}

+ (NSImage *)cvtColorBGR2GRAY:(NSImage *)image {
    cv::Mat bgrMat;
    NSImageToMat(image, bgrMat);
    cv::Mat grayMat;
    cv::cvtColor(bgrMat, grayMat, cv::COLOR_BGR2GRAY);
    NSImage *grayImage = MatToNSImage(grayMat);
    return grayImage;
}

@end
