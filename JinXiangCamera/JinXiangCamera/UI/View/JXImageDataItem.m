//
//  JXImageDataItem.m
//  JinXiangCamera
//
//  Created by Apple on 2021/2/5.
//

#import "JXImageDataItem.h"
#import "JXImageDataView.h"

@interface JXImageDataItem ()

@end

@implementation JXImageDataItem

- (void)setImage:(NSImage *)image {
    _image = image;
    
    JXImageDataView *view = (JXImageDataView *)self.view;
    view.image = image;
}

- (void)loadView {
    self.view = [[JXImageDataView alloc] initWithFrame: NSMakeRect(0, 0, imageListWidth, imageCellHeight)];
    self.view.wantsLayer = YES;//显示View之前调用
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

@end
