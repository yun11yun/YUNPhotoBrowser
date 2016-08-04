//
//  YUNPhotoBrowserCell.m
//  YUNPhotoBrowser
//
//  Created by Orange on 8/3/16.
//  Copyright © 2016 colorcun. All rights reserved.
//

#import "YUNPhotoBrowserCell.h"

@implementation YUNPhotoBrowserCell

- (instancetype)init {
    if (self = [super init]) {
        [self initialziePhotoBrowserCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialziePhotoBrowserCell];
    }
    return self;
}

- (void)initialziePhotoBrowserCell {
    
    _zoomImageView = [[YUNZoomImageView alloc] init];
    [self.contentView addSubview:_zoomImageView];
    
    //下滑或上滑图片
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedImageView:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:upSwipe];
    [_zoomImageView addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedImageView:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:downSwipe];
    [_zoomImageView addGestureRecognizer:downSwipe];
    
    //双击放大图片
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    [_zoomImageView addGestureRecognizer:doubleTap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _zoomImageView.frame = self.contentView.bounds;
}

- (void)swipedImageView:(UISwipeGestureRecognizer *)recognizer {
    if (self.swipeBlock) {
        self.swipeBlock(recognizer.direction);
    }
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    YUNZoomImageView *imageView = (YUNZoomImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = YUNZoomImageViewMaxScale;
    }
    [imageView doubleTapToZoomWithScale:scale];
    
    if (self.doubleTapBlock) {
        self.doubleTapBlock();
    }
}

@end
