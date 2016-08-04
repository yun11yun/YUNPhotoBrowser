//
//  YUNZoomImageView.h
//  YUNZoomImageView
//
//  Created by bit_tea on 16/3/22.
//  Copyright © 2016年 bit_tea. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat YUNZoomImageViewMaxScale;

@interface YUNZoomImageView : UIImageView

@property (nonatomic, readonly, getter=isScaled) BOOL scaled;
@property (nonatomic, assign) BOOL hasLoadedImage;

- (void)eliminateScale; //清除缩放

- (void)doubleTapToZoomWithScale:(CGFloat)scale;

- (void)clear;

@end
