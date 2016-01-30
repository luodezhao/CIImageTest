//
//  MyCollectionCell.m
//  MeiTuXiuXiuTEST
//
//  Created by YB on 16/1/20.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "MyCollectionCell.h"

@implementation MyCollectionCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
}
- (void)setDic:(NSDictionary *)dic {
    self.imgView.image = [self OriginImage:[dic objectForKey:@"image"] scaleToSize:self.imgView.frame.size];
}
-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 2);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

@end
