//
//  JXImageDataItem.h
//  JinXiangCamera
//
//  Created by Apple on 2021/2/5.
//

#import <Cocoa/Cocoa.h>
#import "JXImageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface JXImageDataItem : NSCollectionViewItem

@property(nonatomic,copy)JXImageModel *model;

@end

NS_ASSUME_NONNULL_END
