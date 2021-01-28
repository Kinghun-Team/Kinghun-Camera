//
//  JXImageDataView.m
//  JinXiangCamera
//
//  Created by Apple on 2021/1/5.
//

#import "JXImageDataView.h"

@interface JXImageDataView()<NSTableViewDelegate,NSTableViewDataSource>

@property(nonatomic,strong)NSImageView *imageView;

@property(nonatomic,strong)JHLabel *label;

@end

@implementation JXImageDataView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setImage:(NSImage *)image {
    _image = image;
    
    self.imageView.image = image;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 30, frame.size.width-20, frame.size.height - 40)];
        self.imageView.wantsLayer = YES;
        [self addSubview:self.imageView];
        
        self.label = [[JHLabel alloc] initWithFrame:NSMakeRect(10, 5, frame.size.width-20, 20)];
        self.label.wantsLayer = YES;
        self.label.backgroundColor = [NSColor clearColor];
//        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [NSFont boldSystemFontOfSize:15];
        [self addSubview:self.label];
        
//        NSLog(@"%f,%f",self.imageView.frame.size.width,self.imageView.frame.size.height);
        self.label.text = @"测试图片";
    }
    return self;
}


@end
