//
//  CameraManager.h
//  金翔影像
//
//  Created by Apple on 2020/12/4.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    imageSize1920 = 0,
    imageSize2560 = 1,
    imageSize3840 = 2,
    imageSize4480 = 3,
}ImageSize;

typedef enum {
    Colour          = 0,
    GrayColor       = 1,
    blackAndWhite   = 2,
}ImageModel;

@protocol cameraManagerDelegate<NSObject>

@optional

- (void)cameraBufferIamge:(NSImage *)image;//获取图片

@end

@interface CameraManager : NSObject

@property(nonatomic,assign)BOOL allCamera;//开启获取所有可用摄像头

@property(nonatomic,assign)CGFloat imageScale;//0.5~2.0倍

@property(nonatomic,assign)NSInteger rotate;//旋转角度π/2的倍数 支持0~3,太大会有问题

@property(nonatomic,assign)ImageSize imageSize;//图片大小设置

@property(nonatomic,assign)BOOL isCut;//默认不裁剪

@property(nonatomic,weak)id<cameraManagerDelegate> delegate;

@property (nonatomic,assign) BOOL getPhoto;//获取图片

+ (instancetype)sharedManager;
+ (void)cameraDefaultConfig;//默认设置
+ (NSArray *)cameraDevice;//获取摄像头
- (void)start;//开始取景
- (void)stop;//停止
- (void)setNewAVCapture:(AVCaptureDevice *)device;//设置新的摄像头
- (void)getPhotoImage:(void(^)(NSImage *image))successImage;//获取NSImage对象
- (void)setCameraRGBType:(ImageModel)imageRGB;

- (void)cameraDidSelected;

@end

NS_ASSUME_NONNULL_END
