//
//  MJRefreshBaseView.m
//  MJRefresh
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJRefreshBaseView.h"
#import "MJRefreshConst.h"
#import "UIView+Extension.h"
#import "UIScrollView+Extension.h"
#import <objc/message.h>

@interface  MJRefreshBaseView()
{
    __weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
    __weak UIActivityIndicatorView *_activityView;
    
    UIImageView *_myActivityImage;
    NSMutableArray *_myImages;
}
@end

@implementation MJRefreshBaseView
#pragma mark - 控件初始化
//-(UIImageView *)showTestImage
//{
//    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, -300, 320, 200)];
//    image.backgroundColor = [UIColor redColor];
//    [self addSubview:image];
//    return image;
//}
/**
 *  状态标签
 */
- (UILabel *)statusLabel
{
    if (!_statusLabel) {
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.font = [UIFont boldSystemFontOfSize:13];
        statusLabel.textColor = MJRefreshLabelTextColor;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_statusLabel = statusLabel];
    }
    return _statusLabel;
}

/**
 *  箭头图片
 */
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshSrcName(@"arrow.png")]];
        arrowImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_arrowImage = arrowImage];
        [self activityView];
//        [self showTestImage];
    }
    return _arrowImage;
}

/**
 *  状态标签
 */
- (UIImageView *)activityView
{
/*    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        activityView.autoresizingMask = self.arrowImage.autoresizingMask;
        [self addSubview:_activityView = activityView];
        
        
    }
    return _activityView;
 */
    if(!_myActivityImage)
    {
        _myActivityImage = [[UIImageView alloc]init];
        _myActivityImage.bounds = CGRectMake(0, 0, 100, 100);
        //自动调整子控件与父控件中间的位置
        _myActivityImage.autoresizingMask = self.arrowImage.autoresizingMask;
        _myImages = [[NSMutableArray alloc]init];
        for (int x = 1; x < 81; x ++)
        {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"egg_00%d",x]];
            [_myImages addObject:img];
        }
        
        //设置动画图片数组  数组中存放的是一组UIImage图片
        [_myActivityImage setAnimationImages:_myImages];
        //设置动画持续时间
        [_myActivityImage setAnimationDuration:0.7];
        //设置动画重复次数
        [_myActivityImage setAnimationRepeatCount:HUGE_VALF];
        [self addSubview:_myActivityImage];
    }
    return _myActivityImage;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = MJRefreshViewHeight;
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = MJRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.箭头
    CGFloat arrowX = self.width * 0.5 - 100;
    self.arrowImage.center = CGPointMake(arrowX, self.height * 0.5);
    
    // 2.指示器
//    self.activityView.center = self.arrowImage.center;
    _myActivityImage.center = self.arrowImage.center;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:MJRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        [newSuperview addObserver:self forKeyPath:MJRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 设置宽度
        self.width = newSuperview.width;
        // 设置位置
        self.x = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == MJRefreshStateWillRefreshing) {
        self.state = MJRefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return MJRefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.window) {
        self.state = MJRefreshStateRefreshing;
    } else {
#warning 不能调用set方法
        _state = MJRefreshStateWillRefreshing;
        [super setNeedsDisplay];
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = MJRefreshStateNormal;
    });
}

#pragma mark - 设置状态
- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
    _pullToRefreshText = [pullToRefreshText copy];
    [self settingLabelText];
}
- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
    _releaseToRefreshText = [releaseToRefreshText copy];
    [self settingLabelText];
}
- (void)setRefreshingText:(NSString *)refreshingText
{
    _refreshingText = [refreshingText copy];
    [self settingLabelText];
}
- (void)settingLabelText
{
	switch (self.state) {
		case MJRefreshStateNormal:
            // 设置文字
            self.statusLabel.text = self.pullToRefreshText;
			break;
		case MJRefreshStatePulling:
            // 设置文字
            self.statusLabel.text = self.releaseToRefreshText;
			break;
        case MJRefreshStateRefreshing:
            // 设置文字
            self.statusLabel.text = self.refreshingText;
			break;
        default:
            break;
	}
}

- (void)setState:(MJRefreshState)state
{
    // 0.存储当前的contentInset
    if (self.state != MJRefreshStateRefreshing) {
        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.根据状态执行不同的操作
    switch (state) {
		case MJRefreshStateNormal: // 普通状态
        {
            // 显示箭头
            self.arrowImage.hidden = NO;
            
            // 停止转圈圈
//            [self.activityView stopAnimating];
            [_myActivityImage stopAnimating];
			break;
        }
            
        case MJRefreshStatePulling:
            break;
            
		case MJRefreshStateRefreshing:
        {
            // 开始转圈圈
//			[self.activityView startAnimating];
            [_myActivityImage startAnimating];
            // 隐藏箭头
			self.arrowImage.hidden = YES;
            
            // 回调
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
           
                objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);
            

            }
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
			break;
        }
        default:
            break;
	}
    
    // 3.存储状态
    _state = state;
    
    // 4.设置文字
    [self settingLabelText];
}
@end