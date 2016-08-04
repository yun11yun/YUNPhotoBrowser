//
//  YUNZoomImageView.m
//  YUNZoomImageView
//
//  Created by bit_tea on 16/3/22.
//  Copyright © 2016年 bit_tea. All rights reserved.
//

#import "YUNZoomImageView.h"

const CGFloat YUNZoomImageViewMaxScale = 3.0;

@interface YUNZoomImageView ()

@end

@implementation YUNZoomImageView
{
    UIScrollView *_zoomingScrollView;
    UIImageView *_zoomingImageView;
    CGFloat _currentScale;
}

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    _currentScale = 1.0;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPinched:)];
    [self addGestureRecognizer:pinch];
}

- (void)imageViewPinched:(UIPinchGestureRecognizer *)pinch
{
    [self prepareForImageViewScaling];
    CGFloat scale = pinch.scale;
    CGFloat result;
    if (_currentScale < 1.0) {
        result = _currentScale + (scale - 1) * 0.2;
    } else {
        result = _currentScale + (scale - 1);
    }
    [self zoomWithScale:result];
    pinch.scale = 1.0;
}

- (void)prepareForImageViewScaling
{
    if (!_zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _zoomingScrollView.showsHorizontalScrollIndicator = NO;
        _zoomingScrollView.showsVerticalScrollIndicator = NO;
        _zoomingScrollView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        _zoomingScrollView.contentSize = self.bounds.size;
        [self addSubview:_zoomingScrollView];
        
        _zoomingImageView = [[UIImageView alloc] initWithImage:self.image];
        CGSize imageSize = self.image.size;
        CGFloat imageViewHeight = self.bounds.size.height;
        if (imageSize.width > 0) {
            imageViewHeight = self.bounds.size.width * (imageSize.height / imageSize.width);
        }
        _zoomingImageView.bounds = CGRectMake(0, 0, self.bounds.size.width, imageViewHeight);
        _zoomingImageView.center = _zoomingScrollView.center;
        _zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_zoomingScrollView addSubview:_zoomingImageView];
    }
}

- (void)zoomWithScale:(CGFloat)scale
{
    _currentScale = scale;
    _zoomingImageView.transform = CGAffineTransformMakeScale(scale, scale);
    if (_currentScale < 1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            _zoomingImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _currentScale = 1.0;
        }];
    } else if (_currentScale >= 1.0 && _currentScale <= YUNZoomImageViewMaxScale) {
        
        CGFloat contentWidth = _zoomingImageView.frame.size.width;
        CGFloat contentHeight = MAX(_zoomingImageView.frame.size.height, self.bounds.size.height);
        
        _zoomingImageView.center = CGPointMake(contentWidth / 2, contentHeight / 2);
        _zoomingScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
        CGPoint offset = _zoomingScrollView.contentOffset;
        offset.x = (contentWidth - _zoomingScrollView.frame.size.width) / 2;
        _zoomingScrollView.contentOffset = offset;
    } else if (_currentScale > 3) {
        [UIView animateWithDuration:0.5 animations:^{
            [self zoomWithScale:YUNZoomImageViewMaxScale];
        }];
    }
}
#pragma mark Public Methods

- (void)doubleTapToZoomWithScale:(CGFloat)scale
{
    [self prepareForImageViewScaling];
    [UIView animateWithDuration:0.5 animations:^{
        [self zoomWithScale:scale];
    } completion:^(BOOL finished) {
        if (scale == 1) {
            [self clear];
        }
    }];
}

- (void)eliminateScale
{
    [self clear];
    _currentScale = 1.0;
}

- (void)clear
{
    [_zoomingScrollView removeFromSuperview];
    _zoomingScrollView = nil;
    _zoomingImageView = nil;
}

#pragma mark Properties

- (BOOL)isScaled
{
    return 1.0 != _currentScale;
}

@end
