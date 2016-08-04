//
//  YUNPhotoBrowserCell.h
//  YUNPhotoBrowser
//
//  Created by Orange on 8/3/16.
//  Copyright © 2016 colorcun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUNZoomImageView.h"


@interface YUNPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong, readonly) YUNZoomImageView *zoomImageView;

@property (nonatomic, copy) void(^swipeBlock)(UISwipeGestureRecognizerDirection);

@property (nonatomic, copy) void(^doubleTapBlock)(void);

@end
