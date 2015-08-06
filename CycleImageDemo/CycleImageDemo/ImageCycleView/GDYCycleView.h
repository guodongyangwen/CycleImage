//
//  GDYCycleView.h
//  BSOrange
//
//  Created by juzi on 15/7/13.
//  Copyright (c) 2015年 BazzarEntertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GDYCycleView;
@protocol GDYCycleViewDelegate <NSObject>

-(void)gdyCycleView:(GDYCycleView*)cycleView didSelectItem:(NSInteger)item;

@end

@interface GDYCycleView : UIView
/**
 *  循环播放间隔
 */
@property(nonatomic,assign)CGFloat timeInterval;
/**
 *  点击图片代理
 */
@property(nonatomic,assign)id<GDYCycleViewDelegate> delegate;
/**
 *  播放本地图片数组
 *
 */
-(instancetype)initWithLocalImages:(NSArray*)images;
/**
 *  播放远端图片数组
 */
-(id)initWithRemoteImages:(NSArray*)imageURLs;

/**
 *  控制播放
 */
-(void)startCyclePlay;
-(void)stopCyclePlay;

@end
