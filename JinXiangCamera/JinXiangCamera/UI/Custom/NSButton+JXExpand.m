//
//  NSButton+JXExpand.m
//  JinXiangCamera
//
//  Created by Apple on 2021/3/27.
//

#import "NSButton+JXExpand.h"

@implementation NSButton (JXExpand)

- (void)setTitle:(NSString *)title color:(NSColor *)textColor font:(CGFloat)fontsize;{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = NSMakeRange(0, attrTitle.length);
    [attrTitle addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:fontsize] range:range];
    [attrTitle fixAttributesInRange:NSMakeRange(0, attrTitle.length)];
    [self setAttributedTitle:attrTitle];
    
//    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
//    NSUInteger len = [attrTitle length];
//    NSRange range = NSMakeRange(0, len);
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.alignment = NSTextAlignmentCenter;
//    [attrTitle addAttribute:NSForegroundColorAttributeName value:textColor
//                      range:range];
//    [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:fontsize]
//                      range:range];
//
//    [attrTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle
//                      range:range];
//    [attrTitle fixAttributesInRange:range];
//    [self setAttributedTitle:attrTitle];
//    attrTitle = nil;
//    [self setNeedsDisplay:YES];
}

@end
