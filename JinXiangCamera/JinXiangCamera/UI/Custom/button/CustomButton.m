//
//  CustomButton.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/17.
//

#import "CustomButton.h"

@implementation CustomButton

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _backgroundColor = [NSColor colorWithRed:62/255.f green:175/255.f blue:14/255.f alpha:1];
    _shadowOffset = CGSizeZero;
    _cornerRadius = 4.f;
}

- (void)setTitle:(NSString *)title color:(NSColor *)textColor font:(CGFloat)fontsize;{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSUInteger len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attrTitle addAttribute:NSForegroundColorAttributeName value:textColor
                      range:range];
    [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:fontsize]
                      range:range];
    
    [attrTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle
                      range:range];
    [attrTitle fixAttributesInRange:range];
    [self setAttributedTitle:attrTitle];
    attrTitle = nil;
    [self setNeedsDisplay:YES];
}

/**
 绘制方法由updateLayer替换
 */
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)updateLayer {
    //changed to the width or height of a single source pixel centered at the specified location.
    self.layer.contentsCenter = CGRectMake(0.5, 0.5, 0, 0);
    //setImage
    self.layer.backgroundColor = _backgroundColor.CGColor;
    self.layer.cornerRadius = _cornerRadius;
    self.layer.shadowColor = _backgroundColor.CGColor;
    if (!CGSizeEqualToSize(CGSizeZero, _shadowOffset)) {
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(1, 2);
        self.layer.shadowRadius = 6.f;
        self.layer.shadowOpacity = 1;
    }
}

@end
