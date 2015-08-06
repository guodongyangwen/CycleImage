//
//  JZCycleView.m
//  BSOrange
//
//  Created by juzi on 15/7/13.
//  Copyright (c) 2015年 BazzarEntertainment. All rights reserved.
//

#import "GDYCycleView.h"

const static NSInteger JZMaxSection = 100;

@interface GDYCycleView ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView*   _cycleContainer;
    UIPageControl*      _pageControl;
    NSTimer*            _cyclePlayEngineTimer;
    NSArray*            _cycleImages;
    BOOL                _isRemoteImage;
}
@end

@implementation GDYCycleView

-(id)init{
    if((self = [super init])){
        _timeInterval = 2.5;//默认值
    }
    return self;
}

-(id)initWithLocalImages:(NSArray*)images{
    if((self = [self init])){
        _cycleImages = [[NSArray alloc]initWithArray:images];
        [self addCollectionView];
        [self addPageControl];
        if(_cycleImages.count > 1){//  小于一张图片，默认不循环
            [self addCycleTimer];//默认打开循环播放
        }
    }
    return self;
}

-(id)initWithRemoteImages:(NSArray*)imageURLs{
    _isRemoteImage = YES;
    return [self initWithLocalImages:imageURLs];
}

-(void)setTimeInterval:(CGFloat)timeInterval{
    _timeInterval = timeInterval;
    if(_cyclePlayEngineTimer){
        [self invalidateCycleTimer];
        [self addCycleTimer];
    }else{
        _cyclePlayEngineTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(cyclePlayAction) userInfo:nil repeats:YES];
    }
}

-(void)addCollectionView{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing  = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cycleContainer = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    [_cycleContainer registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    _cycleContainer.showsHorizontalScrollIndicator = NO;
    _cycleContainer.pagingEnabled = YES;
    _cycleContainer.backgroundColor = [UIColor clearColor];
    _cycleContainer.delegate   = self;
    _cycleContainer.dataSource = self;
    [self addSubview:_cycleContainer];
    [self resetIndexPath];
}

-(void)addPageControl{
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.3];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.numberOfPages = _cycleImages.count;
    [self addSubview:_pageControl];
    [self bringSubviewToFront:_pageControl];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _cycleContainer.frame = self.bounds;
    _pageControl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - 12);
}

#pragma mark --共有方法--

-(void)startCyclePlay{
    [self addCycleTimer];
}
-(void)stopCyclePlay{
    [self invalidateCycleTimer];
}


#pragma mark --私有方法

- (void)addCycleTimer{
    if(_cyclePlayEngineTimer){
        [self invalidateCycleTimer];
    }
    _cyclePlayEngineTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(cyclePlayAction) userInfo:nil repeats:YES];
}

-(void)invalidateCycleTimer{
    if(_cyclePlayEngineTimer){
        [_cyclePlayEngineTimer invalidate];
        _cyclePlayEngineTimer = nil;
    }
}


-(void)cyclePlayAction{
    //重置为中间分区对应的item
    NSIndexPath* currentIndexPathReset = [self resetIndexPath];
    if (!currentIndexPathReset) {
        return;
    }
    //计算下一页的indexPath
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if(nextItem == _cycleImages.count){
        nextItem = 0;
        nextSection ++;
    }
    //动画滚动到下一页
    NSIndexPath* nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
    [_cycleContainer scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}


-(NSIndexPath*)resetIndexPath{
    NSIndexPath* currentIndexPath = [[_cycleContainer indexPathsForVisibleItems] lastObject];
    NSIndexPath* currentIndexPathReset = nil;
    if (currentIndexPath) {
        currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:JZMaxSection/2];
        [_cycleContainer scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    return currentIndexPathReset;
}

#pragma mark --UICollectionViewDataSource--

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return JZMaxSection;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _cycleImages.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:101];
    if(!imageView){
        imageView = [[UIImageView alloc]initWithFrame:cell.contentView.bounds];
        imageView.tag = 101;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    }
    if(_isRemoteImage){
//        [imageView sd_setImageWithURL:[NSURL URLWithString:[_cycleImages objectAtIndex:indexPath.item]] placeholderImage:nil];
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_cycleImages objectAtIndex:indexPath.item]]]];
    }else{
        imageView.image = [UIImage imageNamed:[_cycleImages objectAtIndex:indexPath.item]];
    }
    return cell;
}


#pragma mark --UICollectionViewDataSource--

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if([self.delegate respondsToSelector:@selector(gdyCycleView:didSelectItem:)]){
        [self.delegate gdyCycleView:self didSelectItem:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageControl.currentPage = (NSInteger)(_cycleContainer.contentOffset.x / CGRectGetWidth(_cycleContainer.frame) + 0.5) % _cycleImages.count;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _pageControl.currentPage = (NSInteger)(_cycleContainer.contentOffset.x / CGRectGetWidth(_cycleContainer.frame) + 0.5) % _cycleImages.count;
    [_cycleContainer scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_pageControl.currentPage inSection:JZMaxSection/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self invalidateCycleTimer];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = (NSInteger)(_cycleContainer.contentOffset.x / CGRectGetWidth(_cycleContainer.frame) + 0.5) % _cycleImages.count;
    [_cycleContainer scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_pageControl.currentPage inSection:JZMaxSection/2] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self invalidateCycleTimer];
    [self addCycleTimer];
}


@end
