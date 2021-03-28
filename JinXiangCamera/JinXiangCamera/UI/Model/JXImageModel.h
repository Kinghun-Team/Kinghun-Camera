//
//  JXImageModel.h
//  JinXiangCamera
//
//  Created by Apple on 2021/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXImageModel : NSObject

@property(nonatomic,strong)NSImage *imageData;

@property(nonatomic,copy)NSString *fileName;

@end

NS_ASSUME_NONNULL_END
