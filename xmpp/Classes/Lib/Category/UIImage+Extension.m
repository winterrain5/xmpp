//
//  UIImage+Extension.m
//  QQ好友
//
//  Created by 石冬冬 on 15/9/23.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
+ (instancetype)resizeImage:(NSString *)imgName {
    UIImage *bgImage = [UIImage imageNamed:imgName];
    //缩放图片
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width /2
                topCapHeight:bgImage.size.height/2];
    return bgImage;
}

@end
