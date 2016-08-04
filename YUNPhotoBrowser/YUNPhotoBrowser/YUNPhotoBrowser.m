//
//  YUNPhotoBrowser.m
//  YUNPhotoBrowser
//
//  Created by Orange on 8/3/16.
//  Copyright © 2016 colorcun. All rights reserved.
//

#import "YUNPhotoBrowser.h"
#import "YUNPhotoBrowserCell.h"

@interface YUNPhotoBrowser ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, assign) BOOL hasShowedFirst;

@end

static NSString *const kPhotoBrowserCellKey = @"com.yun11yun.photoBrowserCell_Key";

@implementation YUNPhotoBrowser

- (instancetype)init {
    if (self = [super init]) {
        [self initializePhotoBrowser];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializePhotoBrowser];
    }
    return self;
}

- (void)initializePhotoBrowser {
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.collectionView];
    [self addSubview:self.cancelButton];
    [self addSubview:self.indexLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = self.window.bounds;
    
    CGSize viewSize = self.bounds.size;
    
    self.flowLayout.itemSize = CGSizeMake(viewSize.width, viewSize.height);
    self.collectionView.frame = self.bounds;
    
    if (!_hasShowedFirst) {
        [self showFirstImage];
    }
    
    CGFloat cancelWidth = 50;
    self.cancelButton.frame = CGRectMake(10, 20, cancelWidth, cancelWidth);
    self.cancelButton.layer.cornerRadius = cancelWidth / 2;
    
    CGFloat indexLabeWidth = 100;
    self.indexLabel.frame = CGRectMake(viewSize.width - 110, viewSize.height - 40, indexLabeWidth, 20);
}

#pragma mark - Show & Hide

- (void)showFirstImage
{
    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    tempView.frame = rect;
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    self.collectionView.hidden = YES;
    
    [self scrollViewDidScroll:self.collectionView];
    
    [UIView animateWithDuration:0.5 animations:^{
        tempView.center = self.center;
    } completion:^(BOOL finished) {
        self.hasShowedFirst = YES;
        [tempView removeFromSuperview];
        self.collectionView.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.cancelButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.cancelButton.hidden = NO;
        }];
        
    }];
    
}

- (void)cancelButtonClicked:(UIButton *)sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Delegate methods

- (NSInteger)numberOfItems {
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfItemsInPhotoBrowser:)]) {
        return [self.delegate numberOfItemsInPhotoBrowser:self];
    }
    return 0;
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForItemAtIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForItemAtIndex:index];
    }
    return nil;
}

- (NSURL *)imageURLForIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:imageURLForItemAtIndex:)]) {
        return [self.delegate photoBrowser:self imageURLForItemAtIndex:index];
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YUNPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoBrowserCellKey forIndexPath:indexPath];
    if ([self imageURLForIndex:indexPath.row]) {
        
    } else {
        cell.zoomImageView.image = [self placeholderImageForIndex:indexPath.row];
    }
    
    __weak typeof(cell) wCell = cell;
    cell.swipeBlock = ^(UISwipeGestureRecognizerDirection direction){
        [UIView animateWithDuration:0.4 animations:^{
            if (direction == UISwipeGestureRecognizerDirectionUp) {
                wCell.zoomImageView.transform = CGAffineTransformMakeTranslation(0, - self.frame.size.height / 2);
            } else if (direction == UISwipeGestureRecognizerDirectionDown) {
                wCell.zoomImageView.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height / 2);
            }
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    };
    
    cell.doubleTapBlock = ^{
        if (wCell.zoomImageView.isScaled) {
            self.cancelButton.hidden = YES;
        } else {
            self.cancelButton.hidden = NO;
        }
    };
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)innerCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    YUNPhotoBrowserCell *cell = (YUNPhotoBrowserCell *)innerCell;
    [cell.zoomImageView eliminateScale];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.currentImageIndex = (offsetX + 10) / self.bounds.size.width;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",(self.currentImageIndex + 1), [self numberOfItems]];
}

#pragma mark - Getter & Setter

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _flowLayout = flowLayout;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[YUNPhotoBrowserCell class] forCellWithReuseIdentifier:kPhotoBrowserCellKey];
    }
    return _collectionView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.hidden = YES;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont systemFontOfSize:15];
        _indexLabel.textAlignment = NSTextAlignmentRight;
    }
    return _indexLabel;
}

@end
