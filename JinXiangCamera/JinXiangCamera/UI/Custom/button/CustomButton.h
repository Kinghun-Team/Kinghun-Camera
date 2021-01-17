//
//  CustomButton.h
//  JinXiangCamera
//
//  Created by Apple on 2021/1/17.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomButton : NSButton

/**
 背景色 - 默认是APP的蓝色按钮
 */
@property (strong) NSColor *backgroundColor;

/**
 阴影偏移量 - 如果不需要阴影请不要设置
 */
@property (assign) CGSize shadowOffset;

/**
 圆角的半径 - 默认为4
 */
@property (assign) CGFloat cornerRadius;


/**
 设置标题 - 这只是一个快捷方法，你可以根据富文本内容设置更多自定标题

 @param title 内容
 @param textColor 颜色
 */
- (void)setTitle:(NSString *)title color:(NSColor *)textColor font:(CGFloat)fontsize;


@end

NS_ASSUME_NONNULL_END
