//
//  ViewController.m
//  CycleImageDemo
//
//  Created by juzi on 15/8/7.
//  Copyright (c) 2015年 juzi. All rights reserved.
//

#import "ViewController.h"
#import "GDYCycleView.h"
@interface ViewController ()<GDYCycleViewDelegate>
@property(nonatomic,strong)GDYCycleView* cycleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCycleImageView];
}

-(void)setupCycleImageView{
    self.cycleView = [[GDYCycleView alloc]initWithLocalImages:@[@"bg0",@"bg1",@"bg2"]];
    self.cycleView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200);
    self.cycleView.timeInterval = 1;
    self.cycleView.delegate = self;
    [self.view addSubview:_cycleView];
    
}

-(void)gdyCycleView:(GDYCycleView *)cycleView didSelectItem:(NSInteger)item{
    NSLog(@"item:%ld",item);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
