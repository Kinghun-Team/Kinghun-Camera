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
    IMGJPG = 0,
    IMGPNG = 1,
    IMGTIF = 2,
    IMGBMP = 3,
}ImageType;

@protocol cameraManagerDelegate<NSObject>

@optional

-(void)cameraBufferIamge:(NSImage *)image;//获取图片

@end

@interface CameraManager : NSObject

@property(nonatomic,assign)BOOL allCamera;//开启获取所有可用摄像头

@property(nonatomic,assign)ImageSize imageSize;//图片大小设置
@property(nonatomic,assign)ImageType imageType;//图片文件类型

//NSDownloadsDirectory下载  NSDesktopDirectory桌面
@property(nonatomic,assign)NSSearchPathDirectory searchPath;//文件保存路径

@property(nonatomic,weak)id<cameraManagerDelegate> delegate;

+ (instancetype)sharedManager;
+ (void)cameraDefaultConfig;//默认设置
+ (NSArray *)cameraDevice;//获取摄像头

- (void)start;//开始取景
- (void)stop;//停止

- (void)setNewAVCapture:(AVCaptureDevice *)device;//设置新的摄像头
- (void)getPhotoImage:(void(^)(NSImage *image))successImage;//获取NSImage对象

@end

NS_ASSUME_NONNULL_END
