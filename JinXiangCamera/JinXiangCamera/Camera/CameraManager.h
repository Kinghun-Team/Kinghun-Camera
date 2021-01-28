//
//  CameraManager.h
//  金翔影像
//
//  Created by Apple on 2020/12/4.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ImageSize1080 = 0,
    ImageSize1960 = 1,
    ImageSize2560 = 2,
    ImageSize3860 = 3,
}ImageSize;

@protocol cameraManagerDelegate <NSObject>

@optional

-(void)cameraBufferIamge:(NSImage *)image;

@end

@interface CameraManager : NSObject

@property(nonatomic,assign)ImageSize iamgeSize;

@property(nonatomic,weak)id<cameraManagerDelegate> delegate;

+ (instancetype)sharedManager;

+ (void)cameraDefaultConfig;

+ (void)setImageSessionPreset:(AVCaptureSessionPreset)sessionPreset;

- (void)setAVCapture:(AVCaptureDevice *)device;

- (void)start;

- (void)photoSetImage:(NSImageView *)imageView;

- (void)getPhotoImage:(void(^)(NSImage *image))successImage;

@end

NS_ASSUME_NONNULL_END
