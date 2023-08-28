//
//  TLTabBar.m
//  TLKit
//
//  Created by 李伯坤 on 2017/7/18.
//  Copyright © 2017年 李伯坤. All rights reserved.
//

#import "TLTabBar.h"
#import "UITabBarItem+TLPrivateExtension.h"

@interface TLTabBar ()

@property (nonatomic, strong, readonly) NSArray *barControlItems;

@property (nonatomic, assign) UIEdgeInsets oldSafeAreaInsets;

@end

@implementation TLTabBar

- (id)init
{
    if (self = [super init]) {
        self.plusButtonImageOffset = 18;
        self.itemPositioning = UITabBarItemPositioningFill;
        [self setBarTintColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self p_resetTabBarItems];
}

// 响应区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view) {
        return view;
    }
    if (self.hidden) {
        return nil;
    }
    for (UITabBarItem *tabBarItem in self.items) {
        if (tabBarItem.isPlusButton && tabBarItem.tabBarControl) {
            CGRect rect = tabBarItem.tabBarControl.frame;
            if (point.x > rect.origin.x && point.x < rect.origin.x + rect.size.width) {
                CGFloat startY = MIN((rect.size.height - tabBarItem.image.size.height) / 2 - self.plusButtonImageOffset, 0);
                if (point.y < rect.origin.y + rect.size.height && point.y > startY) {
                    return tabBarItem.tabBarControl;
                }
            }
        }
    }
    return nil;
}

#pragma mark - # iOS11 Fixed
- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if(self.oldSafeAreaInsets.left != self.safeAreaInsets.left ||
       self.oldSafeAreaInsets.right != self.safeAreaInsets.right ||
       self.oldSafeAreaInsets.top != self.safeAreaInsets.top ||
       self.oldSafeAreaInsets.bottom != self.safeAreaInsets.bottom) {
        self.oldSafeAreaInsets = self.safeAreaInsets;
        [self invalidateIntrinsicContentSize];
        [self.superview setNeedsLayout];
        [self.superview layoutSubviews];
    }
}

- (CGSize)sizeThatFits:(CGSize) size
{
    CGSize s = [super sizeThatFits:size];
    if(@available(iOS 11.0, *)) {
        CGFloat bottomInset = self.safeAreaInsets.bottom;
        if( bottomInset > 0 && s.height < 50) {
            s.height += bottomInset;
        }
    }
    return s;
}


#pragma mark - # Private Methods
/// 重置TabBarItem持有的Control
- (void)p_resetTabBarItems
{
    NSArray *controlItems = self.barControlItems;
    if (controlItems.count != self.items.count) {
        NSLog(@"p_resetTabBarItems error");
        return;
    }
    
    // 重置图片位置
    [self.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isPlusButton) {
            obj.imageInsets = UIEdgeInsetsMake(-self.plusButtonImageOffset, 0, self.plusButtonImageOffset, 0);
        }
        else {
            if (obj.title.length > 0) {
                obj.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            }
            else {
                obj.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            }
        }
    }];
}

//- (void)p_resetTabBarItemFrames
//{
//    CGFloat itemWidth = self.itemWidth;
//    __block CGFloat x = self.edgeLR;
//    [self.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat radio = obj.isPlusButton ? self.plusItemWidthRatio : 1.0;
//        CGFloat width = itemWidth * radio;
//        [obj.tabBarControl setX:x];
//        [obj.tabBarControl setWidth:width];
//        x += width;
//    }];
//}

#pragma mark - # Getters
- (NSArray *)barControlItems
{
    NSArray *barItems = [self.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *formerView, UIView *latterView) {
        CGFloat startX = formerView.frame.origin.x;
        CGFloat endX = latterView.frame.origin.x;
        return startX > endX ? NSOrderedDescending : NSOrderedAscending;
    }];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (UIControl *control in barItems) {
        if ([control isKindOfClass:[NSClassFromString(@"UITabBarButton") class]]) {
            [data addObject:control];
        }
    }
    return data;
}

@end
