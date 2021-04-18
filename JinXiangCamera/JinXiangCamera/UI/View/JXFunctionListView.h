//
//  JXFunctionListView.h
//  JinXiangCamera
//
//  Created by Apple on 2021/2/6.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXFunctionListView : NSView

@property(nonatomic,strong)JHLabel *imageNameLast;

@property(nonatomic,copy)void(^photoClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
