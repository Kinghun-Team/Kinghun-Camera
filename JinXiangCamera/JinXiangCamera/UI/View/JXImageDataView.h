//
//  JXImageDataView.h
//  JinXiangCamera
//
//  Created by Apple on 2021/1/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXImageDataView : NSView

@property(nonatomic,copy)NSImage *image;

@property(nonatomic,copy)NSString *fileName;

@end

NS_ASSUME_NONNULL_END
