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
#import <opencv2/highgui/highgui_c.h>
#pragma clang diagnostic pop
#import "CameraManager.h"
#import "NSImage+OpenCV.h"

#define cameraManager   [CameraManager sharedManager]

typedef void(^GetImage)(NSImage *image);

double  minThreshold = 10;
double  ratioThreshold = 3;

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

@property (nonatomic,strong) NSDictionary *rgbOutputSettings;

@property (nonatomic,assign)ImageModel imageColor;

@property (nonatomic,assign)CGPoint imageFocus;//图片识别焦点

@property (nonatomic,assign)CGRect cutRect;//裁剪区域

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
        sharedManager.rotate = 0;
        sharedManager.imageSize = imageSize1920;
        sharedManager.imageColor = Colour;
        sharedManager.imageScale = 1.0;
        sharedManager.getPhoto = NO;
        sharedManager.isCut = NO;
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
    [self setCameraRGBType:self.imageColor];
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
//    for (AVCaptureConnection *av in self.videoDataOutput.connections) {
//        if (av.supportsVideoMirroring) {
//            //镜像设置
//            av.videoMirrored = YES;
//        }
//    }
}

- (void)setCameraRGBType:(ImageModel)imageRGB {
    //   设置采集相片的像素格式
    self.rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCMPixelFormat_32BGRA)};
//    if (imageRGB == Colour) {
//        self.rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCMPixelFormat_32BGRA)};
//    } else if (imageRGB == GrayColor) {
//        self.rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
//    } else {
//        self.rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCMPixelFormat_32BGRA)};
//    }
    self.imageColor = imageRGB;
    [self.videoDataOutput setVideoSettings:self.rgbOutputSettings];
    
//    [self.imageOutput setOutputSettings:self.rgbOutputSettings];
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
    [self.session stopRunning];
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
    [self.session startRunning];
}

#pragma mark  AVCaptureVideoDataOutputSampleBufferDelegate 视频流
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
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
    NSSize size = NSMakeSize(self.imageWidth*16.0/9.0, self.imageWidth);
    NSImage *image = [NSImage colorSameBufferImage:sampleBuffer withSize:size];
//    if (self.imageColor == Colour) {
//        image = [NSImage colorSameBufferImage:sampleBuffer withSize:size];
//    } else if (self.imageColor == GrayColor) {
//        image = [NSImage graySameBufferImage:sampleBuffer withSize:size];
//    } else {
//        image = [NSImage covertToGrayScaleImage:sampleBuffer withSize:size];
//    }
    image = [self edgeDetectionToImage:image];
//    if (self.imageColor == GrayColor) {
//        image = [self cvtColorImage:image];
//    }
//    if (self.imageColor == blackAndWhite) {
//        image = [self thresholdImage:image];
//    }
//    self.imageFocus = [self edgeDetectionToImage:image];
//    NSLog(@"%f,%f",self.imageFocus.x,self.imageFocus.y);
    
    NSSize newSzie = size;
    if (abs(self.rotate % 2) == 1) {
        newSzie = NSMakeSize(size.height, size.width);
    }
    image.size = newSzie;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(cameraBufferIamge:)]) {
            [self.delegate cameraBufferIamge:image];
        }
    });
    if (self.getPhoto == YES) {//获取帧
        CGFloat buf = self.imageScale;
        self.imageScale = 1;
        if (self.isCut == YES) {
            image = [NSImage getSubImageFrom:image withRect:self.cutRect];
        }
        getImage(image);
        [[FileManager sharedManager] saveImage:image];
        self.imageScale = buf;
        self.getPhoto = NO;
    }
}

//锁定设备
-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice = [self.input device];
    NSLog(@"对焦模式%ld",(long)captureDevice.focusMode);
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [_session beginConfiguration];
        propertyChange(captureDevice);
        [_session commitConfiguration];
        [captureDevice unlockForConfiguration];
    }
}

//触发聚焦
- (void)cameraDidSelected {
    CGPoint cameraPoint = self.imageFocus;
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        // 触摸屏幕的坐标点需要转换成0-1，设置聚焦点
//        CGPoint cameraPoint = [self.preview captureDevicePointOfInterestForPoint:camera.point];
        /*****必须先设定聚焦位置，在设定聚焦方式******/
        // 聚焦模式
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }else{
            NSLog(@"聚焦模式修改失败");
        }
        //聚焦点的位置
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:cameraPoint];
        }
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光模式修改失败");
        }
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:cameraPoint];
        }
    }];
}

- (NSImage *)edgeDetectionToImage:(NSImage *)image {
    cv::Mat sourceMatImage = image.CVMat;
    cv::Mat grayMatImage;//灰度图
    cv::Mat binaryMatImage;//二值化图
    // 降噪
    blur(sourceMatImage, sourceMatImage, cv::Size(3,3));
    // 转为灰度图
    cvtColor(sourceMatImage, grayMatImage, CV_BGR2GRAY);
    // 二值化
    threshold(grayMatImage, binaryMatImage, 190, 255, CV_THRESH_BINARY);
    // 检测边界
    cv::Mat cannyMatImage;//检测边缘图
    Canny(binaryMatImage, cannyMatImage, minThreshold * ratioThreshold, minThreshold);
    // 获取轮廓
    std::vector<std::vector<cv::Point>> contours;
    findContours(cannyMatImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    // 求所有形状的最小外接矩形中最大的一个
    cv::RotatedRect box;
    for( int i = 0; i < contours.size(); i++ ){
        cv::RotatedRect rect = cv::minAreaRect( cv::Mat(contours[i]) );
        if (box.size.width < rect.size.width) {
            box = rect;
        }
    }
//    self.imageFocus = CGPointMake(box.center.x, box.center.y);//获得焦点
    
    if (self.imageColor == GrayColor) {
        sourceMatImage = grayMatImage;
    }
    if (self.imageColor == blackAndWhite) {
        sourceMatImage = binaryMatImage;
    }
    
    if (self.isCut == YES) {
//        // 画出来矩形和4个点, 供调试。此部分代码可以不要
//        cv::Mat drawing = cv::Mat::zeros(sourceMatImage.rows, sourceMatImage.cols, CV_8UC3);
//        cv::Scalar color = cv::Scalar( rand() & 255, rand() & 255, rand() & 255 );
//        cv::Point2f rect_points[4];
//        box.points( rect_points );
//        for ( int j = 0; j < 4; j++ )
//        {
//            line(drawing, rect_points[j], rect_points[(j+1)%4], color );
//            circle(drawing, rect_points[j], 10, color, 2);
//        }
//
//        sourceMatImage = drawing;
        
        std::vector<cv::Point2f> corners;
        
        int maxCorners = 8; // // 最多检测到的角点数, 12
        double qualityLevel = 0.05; // 阈值系数 0.01
        double minDistance = 10; // 角点间的最小距离 10
        int blockSize = 10; // 计算协方差矩阵时的窗口大小 10
        bool useHarrisDetector = false; // 是否使用Harris角点检测，如不指定，则计算shi-tomasi角点, false
        double k = 0.04; // Harris角点检测需要的k值 0.04
        
        cv::goodFeaturesToTrack(cv::InputArray(grayMatImage), cv::OutputArray(corners), maxCorners, qualityLevel, minDistance, cv::Mat(), blockSize, useHarrisDetector, k);
        
        //建立包围所有角点的矩形
        cv::Rect rect = cv::boundingRect(cv::InputArray(corners));
        
        self.cutRect = CGRectMake(rect.x, rect.y, rect.width, rect.height);
        self.imageFocus = CGPointMake(rect.x+rect.width/2,rect.y+rect.height/2);
        NSLog(@"%d,%d",rect.width,rect.height);
        
        //把每个检测到的角点在图中用圆形标识出来(方便调试)
//        for( int i = 0; i < corners.size(); i++ )
//        {
//            cv::circle(cv::InputOutputArray(grayMatImage), corners[i], 10, cv::Scalar(0,255,0), 2, 8, 0);
//        }
        //把包围所有角点的矩形也画出来(方便调试)
        cv::rectangle(sourceMatImage, rect, cv::Scalar(255,255,0), 2, 8, 0);
        
//        sourceMatImage = eyeImg;
    }
    
    /*
     *  重新绘制轮廓
     */
    // 初始化一个8UC3的纯黑图像
//    Mat dstImg(sourceMatImage.size(), CV_8UC3, Scalar::all(0));
//    // 用于存放轮廓折线点集
//    std::vector<std::vector<cv::Point>> contours_poly(contours.size());
//    // STL遍历
//    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
//    std::vector<std::vector<cv::Point>>::const_iterator itContourEnd = contours.end();
//    // ++i 比 i++ 少一次内存写入,性能更高
//    for (int i=0 ; itContours != itContourEnd; ++itContours,++i) {
//        approxPolyDP(Mat(contours[i]), contours_poly[i], 15, true);
//        // 绘制处理后的轮廓,可以一段一段绘制,也可以一次性绘制
//        // drawContours(dstImg, contours_poly, i, Scalar(208, 19, 29), 8, 8);
//    }
//
//    /*如果C++ 基础不够,可以使用 for 循环
//     *    for (int i = 0; i < contours.size(); i ++) {
//     *        approxPolyDP(contours[i] , contours_poly[i], 5, YES);
//     *    }
//     */
//
//    // 绘制处理后的轮廓,一次性绘制
//    drawContours(dstImg, contours_poly, -1, Scalar(208, 19, 29), 8, 8);
    // 显示绘制结果
//    self.desImageView.image = MatToUIImage(dstImg);
    
    return [[NSImage alloc] initWithCVMat:sourceMatImage];
}

- (NSImage *)cvtColorImage:(NSImage *)image {
    cv::Mat sourceMatImage = image.CVMat;
    // 降噪
    blur(sourceMatImage, sourceMatImage, cv::Size(3,3));
    // 转为灰度图
    cvtColor(sourceMatImage, sourceMatImage, CV_BGR2GRAY);
    
    return [[NSImage alloc] initWithCVMat:sourceMatImage];
}

- (NSImage *)thresholdImage:(NSImage *)image {
    cv::Mat sourceMatImage = image.CVMat;
    // 降噪
    blur(sourceMatImage, sourceMatImage, cv::Size(3,3));
    // 转为灰度图
    cvtColor(sourceMatImage, sourceMatImage, CV_BGR2GRAY);
    // 二值化
    threshold(sourceMatImage, sourceMatImage, 190, 255, CV_THRESH_BINARY);
    
    return [[NSImage alloc] initWithCVMat:sourceMatImage];
}

- (void)getPhotoImage:(void(^)(NSImage *image))successImage {
    NSLog(@"点击拍照!");
    self.getPhoto = YES;
    getImage = ^(NSImage *image) {
        successImage(image);
    };
}

@end
