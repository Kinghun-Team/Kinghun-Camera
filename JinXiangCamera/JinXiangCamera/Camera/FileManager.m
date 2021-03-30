//
//  FileManager.m
//  JinXiangCamera
//
//  Created by Apple on 2021/3/30.
//

#import "FileManager.h"


@interface FileManager()

@property(nonatomic,assign)NSInteger imageCount;

@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileType;

@property (nonatomic,assign) ImageType imageType;//图片文件类型
@property (nonatomic,assign) ImageFileName fileNameType;

@property (nonatomic,strong) NSDateFormatter *formatter;

@end

@implementation FileManager

+ (instancetype)sharedManager {
    static FileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[FileManager alloc] init];
        [sharedManager choiceImageType:IMGPNG];
        sharedManager.searchPath = NSDownloadsDirectory;
        sharedManager.imageCount = 1;
        sharedManager.imageFirstName = @"IMG";
        sharedManager.imageLastName = @"000001";
        [sharedManager setImageName:FileDate];
        sharedManager.isSystemFileSave = YES;
    });
    return sharedManager;
}

- (void)setImageFirstName:(NSString *)imageFirstName {
    _imageFirstName = imageFirstName;
    self.imageCount = 1;
    NSString *t = [NSString stringWithFormat:@"%@%ld",@"0000000",self.imageCount];
    NSRange ange = {t.length-6,6};
    self.imageLastName = [t substringWithRange:ange];
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    }
    return _formatter;
}

- (void)setImageName:(ImageFileName)fileNameType {
    self.fileNameType = fileNameType;
}

- (void)choiceImageType:(ImageType)type {
    self.imageType = type;
    switch (self.imageType) {
        case IMGPNG:
            self.fileType = @"png";
            break;
        case IMGJPG:
            self.fileType = @"jpg";
            break;
        case IMGTIF:
            self.fileType = @"TIF";
            break;
        case IMGBMP:
            self.fileType = @"BMP";
            break;
        default:
            break;
    }
}

#pragma - 保存图片
- (void)saveImage:(NSImage *)image {
    [image lockFocus];
    NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [image unlockFocus];
    
    //再设置后面要用到得 props属性
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:NSImageCompressionFactor];
    //之后 转化为NSData 以便存到文件中
    NSBitmapImageFileType imageType = NSPNGFileType;
    switch (self.imageType) {
        case IMGPNG:
            imageType = NSPNGFileType;
            break;
        case IMGJPG:
            imageType = NSBitmapImageFileTypeJPEG;
            break;
        case IMGTIF:
            imageType = NSBitmapImageFileTypeTIFF;
            break;
        case IMGBMP:
            imageType = NSBitmapImageFileTypeBMP;
            break;
        default:
            break;
    }
    if (self.fileNameType == FileDate) {
        self.fileName = [self.formatter stringFromDate:[NSDate date]];
    } else {
        NSString *t = [NSString stringWithFormat:@"%@%ld",@"0000000",self.imageCount];
        NSRange ange = {t.length-6,6};
        self.fileName = [NSString stringWithFormat:@"%@%@",self.imageFirstName,[t substringWithRange:ange]];
        self.imageLastName = [[NSString stringWithFormat:@"%@%ld",@"0000000",self.imageCount+=1] substringWithRange:ange];
    }
    NSData *imageData = [bits representationUsingType:imageType properties:imageProps];
    NSURL *url = [[NSFileManager defaultManager] URLsForDirectory:self.searchPath inDomains:NSUserDomainMask].firstObject;
    [self createFile:[NSString stringWithFormat:@"%@.%@",self.fileName,self.fileType] withUrl:url withFileData:imageData];
}

- (void)createFile:(NSString *)name withUrl:(NSURL *)fileBaseUrl withFileData:(NSData *)data {
    if (self.getImageName) {
        self.getImageName(name);
    }
    NSString *path;
    if (self.isSystemFileSave == YES) {
        NSURL *file = [fileBaseUrl URLByAppendingPathComponent:name];
        path = file.path;
    } else {
        path = [self.userFilePath stringByAppendingFormat:@"/%@", name];
    }
    BOOL isSuccess = [data writeToFile:[path stringByExpandingTildeInPath] atomically:YES];
    NSLog(@"Save Image: %d", isSuccess);
}

@end
