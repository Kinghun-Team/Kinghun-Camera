//
//  SeveData.h
//  JinXiangCamera
//
//  Created by Apple on 2021/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#define FileSeveData [SeveData initData]

#define JXSelectSize                @"selectSize"
#define JXSelectImageType           @"selectImageType"
#define JXFileSelectIndex           @"fileSelectIndex"
#define JXFileArray                 @"fileArray"

@interface SeveData : NSObject

+ (SeveData *)initData;

@property(nonatomic,assign)NSInteger selectSize;

@property(nonatomic,assign)NSInteger selectImageType;

@property(nonatomic,assign)NSInteger fileSelectIndex;

@property(nonatomic,strong)NSMutableArray *fileArray;

@end

NS_ASSUME_NONNULL_END
