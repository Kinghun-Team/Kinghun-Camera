//
//  NSImage+OpenCV.h
//  金翔影像
//
//  Created by Apple on 2020/12/26.
//

#import <opencv2/opencv.hpp>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (OpenCV)

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end

NS_ASSUME_NONNULL_END