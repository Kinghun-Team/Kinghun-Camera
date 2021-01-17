//
//  CameraManager.h
//  金翔影像
//
//  Created by Apple on 2020/12/4.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraManager : NSObject

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

+ (instancetype)sharedManager;

+ (void)cameraDefaultConfig;

+ (void)setImageSessionPreset:(AVCaptureSessionPreset)sessionPreset;

- (void)startCameraToView:(NSView *)view;

- (void)photoSetImage:(NSImageView *)imageView;

//opencv
- (id)initWithController:(NSViewController*)c andCameraImageView:(NSImageView*)iv processImage:(NSImageView *)processIv;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
