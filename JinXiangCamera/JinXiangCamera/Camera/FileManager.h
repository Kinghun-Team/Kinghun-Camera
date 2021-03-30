//
//  FileManager.h
//  JinXiangCamera
//
//  Created by Apple on 2021/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    IMGJPG = 0,
    IMGPNG = 1,
    IMGTIF = 2,
    IMGBMP = 3,
}ImageType;

typedef enum {
    FileDate   = 0,
    FileCustom = 1,
}ImageFileName;

@interface FileManager : NSObject

@property(nonatomic,copy)void(^getImageName)(NSString *fileName);
@property(nonatomic,copy)NSString *imageFirstName;
@property(nonatomic,strong)NSString *imageLastName;

@property(nonatomic,assign)BOOL isSystemFileSave;
@property(nonatomic,copy)NSString *userFilePath;

//NSDownloadsDirectory下载  NSDesktopDirectory桌面
@property(nonatomic,assign)NSSearchPathDirectory searchPath;//文件保存路径

+ (instancetype)sharedManager;
- (void)choiceImageType:(ImageType)type;
- (void)setImageName:(ImageFileName)fileNameType;
- (void)saveImage:(NSImage *)image;

@end

NS_ASSUME_NONNULL_END
