//
//  ViewController.m
//  MeiTuXiuXiuTEST
//
//  Created by YB on 16/1/15.
//  Copyright © 2016年 YB. All rights reserved.
//

#import "ViewController.h"
#import "MyCollectionCell.h"
@interface ViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    CIFilter *filter;
    
    CIContext *context;
    
    UIImagePickerController *imgPick;
    
    NSMutableArray *dataSource;
}
@property (nonatomic,strong) IBOutlet UIImageView *imgView;
@property (nonatomic,strong) IBOutlet UISlider *sliderSaturation;
@property (nonatomic,strong) IBOutlet UISlider *sliderBrightness;
@property (nonatomic,strong) IBOutlet UISlider *sliderContrast;
@property (nonatomic,strong) IBOutlet UIButton *btnPicture;
@property (nonatomic,strong) IBOutlet UIButton *btnSave;
@property (nonatomic,strong) IBOutlet UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imgPick = [[UIImagePickerController alloc]init];
    imgPick.delegate = self;
    
    [self setSliders];
    [self setButtons];
    [self setFilter];
    [self setDataSource];
    [self setCollection];
    
    
}
- (void)setDataSource {
    dataSource = [[NSMutableArray alloc]init];
    NSArray *typeArray = [NSArray arrayWithObjects:@"CIPhotoEffectChrome",@"CIPhotoEffectFade",@"CIPhotoEffectInstant",@"CIPhotoEffectMono",@"CIPhotoEffectNoir",@"CIPhotoEffectProcess",@"CIPhotoEffectTonal",@"CIPhotoEffectTransfer",@"CISepiaTone",nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for ( NSString *str in typeArray) {
            CIFilter *myFilter = [CIFilter filterWithName:str];
            [myFilter setValue:[CIImage imageWithCGImage:self.imgView.image.CGImage] forKey:@"inputImage"];
            CIImage *image = [myFilter outputImage];
           CIContext *myContext = [CIContext contextWithOptions:nil];
            CGImageRef temp = [myContext createCGImage:image fromRect:[image extent]];
            UIImage *newImage = [UIImage imageWithCGImage:temp];
            CGImageRelease(temp);
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[newImage] forKeys:@[@"image"]];
            [dataSource addObject:dic];
            image = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];

        });
    });
    
}
- (void)setCollection {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MyCollectionCell"];
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionCell" forIndexPath:indexPath];
    cell.dic = [dataSource objectAtIndex:indexPath.item];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.imgView.image = [[dataSource objectAtIndex:indexPath.item] objectForKey:@"image"];
    self.sliderBrightness.value = 0;
    self.sliderContrast.value = 1;
    self.sliderSaturation.value = 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dataSource.count;
}
- (void)setButtons {
    [self.btnPicture addTarget:self action:@selector(btnPicClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSave addTarget:self action:@selector(savePic) forControlEvents:UIControlEventTouchUpInside];
}
- (void)btnPicClick {
    UIActionSheet * a = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    [a showInView:self.view];
}
-  (void)savePic {
    UIImageWriteToSavedPhotosAlbum(self.imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        imgPick.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPick.showsCameraControls = YES;
        
    }else if (buttonIndex == 1)
    {
        imgPick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imgPick animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imgView.image =[self imageByScalingAndCroppingForSize:self.imgView.frame.size im:[self fixOrientation:original]];
//    self.imgView.image = [self fixOrientation:original];
    NSLog(@"%ld",original.imageOrientation);
    [filter setValue:[CIImage imageWithCGImage:self.imgView.image.CGImage] forKey:@"inputImage"];//设置
    [imgPick dismissViewControllerAnimated:YES completion:nil];
    [self setDataSource];
}
- (UIImage *)fixOrientation:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (void)setSliders {
    [self.sliderSaturation addTarget:self action:@selector(changeSaturation:) forControlEvents:UIControlEventValueChanged];
    self.sliderSaturation.minimumValue = 0;
    self.sliderSaturation.maximumValue = 2;
    self.sliderSaturation.value = 1;
    
    [self.sliderBrightness addTarget:self action:@selector(changeBrigtness:) forControlEvents:UIControlEventValueChanged];
    self.sliderBrightness.minimumValue = -1;
    self.sliderBrightness.maximumValue = 1;
    self.sliderBrightness.value = 0;
    
    
    [self.sliderContrast addTarget:self action:@selector(changeContrast:) forControlEvents:UIControlEventValueChanged];
    self.sliderContrast.minimumValue = 0;
    self.sliderContrast.maximumValue = 2;
    self.sliderContrast.value = 1;
    
    
}
- (void)setFilter {
    filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:[CIImage imageWithCGImage:self.imgView.image.CGImage] forKey:@"inputImage"];//设置滤镜的输入图片
}
- (void)changeSaturation:(UISlider *)slider {
    [filter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputSaturation"];
    [self setIMage];
}
- (void)changeBrigtness:(UISlider *)slider {
    [filter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputBrightness"];
    [self setIMage];//-1到1
}
- (void)changeContrast:(UISlider *)slider {
    [filter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputContrast"];
    [self setIMage];//0到2
}

- (void)setIMage {
    CIImage *image = [filter outputImage];
    context = [CIContext contextWithOptions:nil];
    CGImageRef temp = [context createCGImage:image fromRect:[image extent]];
    self.imgView.image = [UIImage imageWithCGImage:temp];
    CGImageRelease(temp);
    temp = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
//    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    UIGraphicsBeginImageContextWithOptions(size, YES, 2);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize im:(UIImage *)img
{
    UIImage *sourceImage = img;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 2);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
