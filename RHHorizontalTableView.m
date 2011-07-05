/*
 * RHHorizontalTableView.m
 * RHHorizontalTableView
 * 
 * Created by Rick Harrison on 6/28/11.
 * Copyright (c) 2011 Rick Harrison, http://rickharrison.me
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <objc/runtime.h>
#import "RHHorizontalTableView.h"

CGFloat const RHHorizontalTableViewScrollIndicatorPositionBottomOffset = 9.0;

@interface RHHorizontalTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation RHHorizontalTableView

@synthesize indicatorPosition = _indicatorPosition;

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ((self = [super initWithFrame:frame style:style])) {
        self.transform = CGAffineTransformMakeRotation(-1 * M_PI / 2.0);
        self.frame = frame;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        CGRect _beforeRotationFrame = self.frame;
        self.transform = CGAffineTransformMakeRotation(-1 * M_PI / 2.0);
        self.frame = _beforeRotationFrame;
    }
    return self;
}

#pragma mark -
#pragma mark Appearance Configuration

- (void)setIndicatorPosition:(RHHorizontalTableViewScrollIndicatorPosition)indicatorPosition {
    _indicatorPosition = indicatorPosition;
    
    if (indicatorPosition == RHHorizontalTableViewScrollIndicatorPositionTop) {
        self.scrollIndicatorInsets = UIEdgeInsetsZero;
    } else if (indicatorPosition == RHHorizontalTableViewScrollIndicatorPositionBottom) {
        self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, self.frame.size.height - RHHorizontalTableViewScrollIndicatorPositionBottomOffset);
    }
}

#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_realDataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_realDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        cell.backgroundView.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
        cell.selectedBackgroundView.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_realDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return 0.1;
    }
    
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_realDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *headerView = [_realDelegate tableView:tableView viewForHeaderInSection:section];
        
        CGFloat desiredHeight = CGRectGetHeight(headerView.frame);
        
        if ([_realDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
            desiredHeight = [_realDelegate tableView:tableView heightForHeaderInSection:section];
        }
        
        headerView.frame = CGRectMake(0, 0, CGRectGetWidth(headerView.frame), desiredHeight);
        
        /*
         * Create a wrapper for the desired header view and rotate it
         */
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.autoresizingMask = UIViewAutoresizingNone;
        view.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
        
        [view addSubview:headerView];
        
        return [view autorelease];
    }
    
    return nil;
}

#pragma mark -
#pragma mark Protocol/Message Forwarding

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL result = [super respondsToSelector:aSelector];
    
    /*
     * Check if the selector is part of the UITableViewDataSource protocol.
     */
    
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), aSelector, NO, YES);
    
    if (dataSourceMethod.name != nil) {
        result = [_realDataSource respondsToSelector:aSelector];
    }
    
    /*
     * Check if the selector is part of the UITableViewDelegate protocol.
     */
    
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), aSelector, NO, YES);
    
    if (delegateMethod.name != nil) {
        result = [_realDelegate respondsToSelector:aSelector];
    }
    
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    /*
     * Check if the selector is part of the UITableViewDataSource protocol.
     */
    
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), aSelector, NO, YES);
    
    if (dataSourceMethod.name != nil) {
        signature = [(NSObject *)_realDataSource methodSignatureForSelector:aSelector];
    }
    
    /*
     * Check if the selector is part of the UITableViewDelegate protocol.
     */
    
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), aSelector, NO, YES);
    
    if (delegateMethod.name != nil) {
        signature = [(NSObject *)_realDelegate methodSignatureForSelector:aSelector];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), selector, NO, YES);
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), selector, NO, YES);
    
    /*
     * Route the invocation to the original data source, delegate, or super
     */
    
    if (dataSourceMethod.name != nil && [_realDataSource respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:_realDataSource];
    } else if (delegateMethod.name != nil && [_realDelegate respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:_realDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

#pragma mark -
#pragma mark Overrides

- (void)setDataSource:(id <UITableViewDataSource>)dataSource {
    _realDataSource = dataSource;
    
    [super setDataSource:self];
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate {
    _realDelegate = delegate;
    
    [super setDelegate:self];
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}

@end
