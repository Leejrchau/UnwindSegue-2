/*
     File: QuizContainerViewController.m
 Abstract: A custom container view controller that is functionally similar to a 
 UINavigationController.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "QuizContainerViewController.h"
#import "QuizContainerFadeViewControllerSegue.h"

#import <QuartzCore/QuartzCore.h>

// 这个控制器充当的是导航的角色(如果需要把一个视图控制器 自定义成一个导航控制器的话，用storyboard 拖拽一个视图控制器，然后将view删除，这样就可以做为自定义的导航视图控制器了)
@interface QuizContainerViewController () <UINavigationBarDelegate> {
    UINavigationBar *_navigationBar;
    NSArray *_viewControllers;
}
@end


@implementation QuizContainerViewController

//| ----------------------------------------------------------------------------
//  We provide our own view.
//
// 往内存中加载视图的时候 会调用这个方法(如果你要是实现这个loadView方法，注意这个时候self.view 还没有创建，所以我们必须创建view self.view = [[UIView alloc] init];如果我们不创建 那么会报错。如果我们不实现loadView方法，编译器会自动执行父类中的这个方法。父类中这个方法帮我们创建了View)
- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    _navigationBar = [[UINavigationBar alloc] init];
    _navigationBar.delegate = self;
    [self.view addSubview:_navigationBar];
}

//加载到内存后，将要显示view的时候调用这个方法 （在viewDidLoad后面）
-(void)viewWillAppear:(BOOL)animated
{
    
}

//| ----------------------------------------------------------------------------
// 加载到内存后 会调用这个方法
- (void)viewDidLoad
{
    // The transition animation involves fading out the outgoing view
    // controller's view while fading in the incoming view controller's view.
    // This creates a short 'flash' animation where the color of the flash is 
    // our view's backgroundColor.
       self.view.backgroundColor = [UIColor whiteColor];
    
    // This segue creates our initial root view controller.  Users of this
    // class are expected to define a segue named 'RootViewController' with
    // segue type QuizContainerRootViewControllerSegue.  The destination
    // of this segue should be the scene of the desired initial root view
    // controller.
    [self performSegueWithIdentifier:@"RootViewController" sender:self];
}


//| ----------------------------------------------------------------------------
//! Returns the appropriate frame for displaying a child view controller.
//
- (CGRect)frameForTopViewController
{
    return CGRectMake(0,
                      _navigationBar.frame.size.height + _navigationBar.frame.origin.y,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - _navigationBar.frame.size.height - _navigationBar.frame.origin.y);
}


//| ----------------------------------------------------------------------------
//当视图布局发生 了变化 需要调整子视图 那么会调用这个方法
- (void)viewDidLayoutSubviews
{
    // 将_navigationBar 调整到最佳尺寸
    [_navigationBar sizeToFit];
    
    // Offset the navigation bar to account for the status bar.
    CGFloat topLayoutGuide = 0.0f;
    if ([self respondsToSelector:@selector(topLayoutGuide)])
        topLayoutGuide = [self.topLayoutGuide length];
    //调整导航条的位置
    _navigationBar.frame = CGRectMake(_navigationBar.frame.origin.x, topLayoutGuide,
                                      _navigationBar.frame.size.width, _navigationBar.frame.size.height);
//    调整topViewController的位置
    self.topViewController.view.frame = [self frameForTopViewController];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue is  %@",[segue class]);
}


#pragma mark -
#pragma mark Unwind Segue

//| ----------------------------------------------------------------------------
//! Returns the view controller managed by the receiver that wants to handle
//! the specified unwind action.
//
//  This method is called when either unwind segue is triggered in
//  ResultsViewController.  It is the responsibility of the parent of the
//  view controller that triggered the unwind segue to locate a
//  view controller that responds to the unwind action for the triggered segue.
//  
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    // Like UINavigationController, search the array of view controllers
    // managed by this container in reverse order.
    for (UIViewController *vc in [_viewControllers reverseObjectEnumerator])
        // Always use -canPerformUnwindSegueAction:fromViewController:withSender:
        // to determine if a view controller wants to handle an unwind action.
        if ([vc canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender])
            return vc;
    
    // Always invoke the super's implementation if no view controller managed
    // by this container wanted to handle the unwind action.
    return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}


//| ----------------------------------------------------------------------------
//! Returns a segue object for transitioning to toViewController.
//
//  This method is called if the destination of an unwind segue is a child
//  view controller of this container.  This method returns an instance
//  of QuizContainerFadeViewControllerSegue that transitions to the destination
//  view controller of the unwind segue (toViewController).
//
- (UIStoryboardSegue*)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    // QuizContainerFadeViewControllerSegue is a UIStoryboardSegue subclass
    // for transitioning between view controllers managed by this container.
    QuizContainerFadeViewControllerSegue *unwindStoryboardSegue = [[QuizContainerFadeViewControllerSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    
    // Set the unwind property to YES so an unwind animation is performed.
    // Note that this property is custom to QuizContainerFadeViewControllerSegue.
    unwindStoryboardSegue.unwind = YES;
    
    return unwindStoryboardSegue;
}

#pragma mark -
#pragma mark Actions

//| ----------------------------------------------------------------------------
//! Manual implementation of the topViewController property.
//! Returns the view controller at the top of the navigation stack.
//
- (UIViewController*)topViewController
{
    if (self.viewControllers.count == 0)
        return nil;
    return [self.viewControllers lastObject];
}


//| ----------------------------------------------------------------------------
//! Manual implementation of the getter for the viewControllers property.
//! Returns an array containing the view controllers currently on the
//! navigation stack.
//
- (NSArray*)viewControllers
{
    // This method is called by MainMenuViewController which then accesses
    // the first view controller in the array.  This occurs before our
    // view has been loaded (-viewDidLoad has not been called) which means
    // our initial root view controller has not been created yet (that happens
    // in -viewDidLoad).  But we must not return an empty array, so we force an
    // early load of our view here.
    [self view];
    
    return _viewControllers;
}


//| ----------------------------------------------------------------------------
//! Equivalent to calling -setViewControllers:animated: and passing NO for the
//! animated argument.
//
- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}


//| ----------------------------------------------------------------------------
//! Replaces the view controllers currently managed by the receiver with the
//! specified items.
//
//! @param  viewControllers
//!         The view controllers to place in the navigation stack.  The
//!         last item added to the array becomes the top item of the
//!         navigation stack.
//! @param  animated
//!         If YES, animate the pushing or popping of the top view controller.
//!         If NO, replace the view controllers without any animations.
//
//  This is where all of the transition magic happens. 
//
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    // Compare the incoming viewControllers array to the existing navigation
    // stack, seperating the differences into two groups.
    //
    
    //    执行下面的代码 下面执行的是一个谓词过滤，这个谓词是“不在viewControllers数组中的元素”，下面整句代码的意思是将_viewControllers数组中每个元素都执行这个谓词，将 “不在viewControllers数组中的元素”放到一个新的数组返回。这样我们就把那些在_viewController中的元素，不在viewControllers数组中的元素找出来了，这些元素组成了一个数组返回回来，这些元素就是我们需要删除的元素。

    NSArray *viewControllersToRemove = [_viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", viewControllers]];
    
//    执行下面的代码 下面执行的是一个谓词过滤，这个谓词是“不在_viewControllers数组中的元素”，下面整句代码的意思是将viewControllers数组中每个元素都执行这个谓词，将 “不在_viewControllers数组中的元素”放到一个新的数组返回。这样我们就把那些在viewController中的元素，不在_viewControllers数组中的元素找出来了，这些元素组成了一个数组返回回来，这些元素就是我们要添加进来的元素。
    NSArray *viewControllersToAdd = [viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", _viewControllers]];
    
    for (UIViewController *vc in viewControllersToRemove)
        [vc willMoveToParentViewController:nil];//当容器视图控制器要添加或者删除视图控制器的时候，必须调用这个方法
    
    for (UIViewController *vc in viewControllersToAdd)
        [self addChildViewController:vc];//在调用这个方法的时候 ，程序会自动调用willMoveToParentViewController方法，不必我们 手动调用，但是如果要删除 （调用removeFromParentViewController）我们就必须手动调用willMoveToParentViewController方法
    
    void (^finishRemovingViewControllers)() = ^() {
        for (UIViewController *vc in viewControllersToRemove)
            [vc removeFromParentViewController];//在调用这个方法的时候，必须自己手动调用willMoveToParentViewController方法。这就是为什么260行我们写那句代码的原因了。
    };
    
    void (^finishAddingViewControllers)() = ^() {
        for (UIViewController *vc in viewControllersToAdd)
            [vc didMoveToParentViewController:self];//如果是addChildViewController的时候，如果添加完成以后，必须手动调用didMoveToParentViewController 这个方法。removeFromParentViewController的时候，会自动调用didMoveToParentViewController方法，不必我们手动调用。
    };
    
    /*
     总结上面几句代码，我们发现，删除之前要手动调用willMoveToParentViewController方法，添加之后需要手动调用didMoveToParentViewController方法。添加之前系统会自动调用willMoveToParentViewController方法，删除之后系统会自动点用didMoveToParentViewController方法
     
    */
    
    // The view controller presently at the top of the navigation stack.
    //获取原来的顶部视图控制器
    UIViewController *oldTopViewController = (_viewControllers.count) ? [_viewControllers lastObject] : nil;
//    获取当前顶部视图控制器
    // The view controller that will be at the stop of the navgation stack.
    UIViewController *newTopViewController = (viewControllers.count) ? [viewControllers lastObject] : nil;

    // If the last object in the incoming viewControllers is the
    // already at the top of the current navigation stack then don't 
    // perform any animation as it would be redundant.
//    如果两个视图控制器不一样
    if (oldTopViewController != newTopViewController)
    {
        if (oldTopViewController)
        {
            // Fade animations look wrong unless the root layer of the
            // animation rasterizes itself but be sure to remember the
            // old setting.
            //shouldRasterize 是一个布尔值 用来表示 layer在位图合成之前是否已经渲染
            BOOL oldTopViewControllerViewShouldRasterize = oldTopViewController.view.layer.shouldRasterize;
            oldTopViewController.view.layer.shouldRasterize = YES;
            
            // Fade out the old top view controller of the navigation stack.
            [UIView animateWithDuration:((animated) ? 0.25 : 0) delay:0 options:0 animations:^{
                oldTopViewController.view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                // Restore the old shouldRasterize setting.
                oldTopViewController.view.layer.shouldRasterize = oldTopViewControllerViewShouldRasterize;
                // 将原来的视图控制器的视图从父视图中删除
                [oldTopViewController.view removeFromSuperview];
//                （删除视图后，只是从视觉上看不到顶部视图了，但是试图控制器上的父子关联关系还没有解除，所以要解除父子关联关系）
                finishRemovingViewControllers();
            }];
        }
        else
            finishRemovingViewControllers();
        
        if (newTopViewController)
        {
            // Fade animations look wrong unless the root layer of the
            // animation rasterizes itself but be sure to remember the
            // old setting.
            BOOL newTopViewControllerViewShouldRasterize = newTopViewController.view.layer.shouldRasterize;
            newTopViewController.view.layer.shouldRasterize = YES;
            //设定新的顶部视图控制器的frame
            newTopViewController.view.frame = [self frameForTopViewController];
            //将顶部视图控制器的视图添加进来
            [self.view addSubview:newTopViewController.view];
            
            newTopViewController.view.alpha = 0.0f;
            
            // Fade in the new top view controller of the navigation stack.
            [UIView animateWithDuration:((animated) ? 0.25 : 0) delay:((animated) ? 0.3 : 0) options:0 animations:^{
                newTopViewController.view.alpha = 1.0f;
            } completion:^(BOOL finished) {
                // Restore the old shouldRasterize setting.
                newTopViewController.view.layer.shouldRasterize = newTopViewControllerViewShouldRasterize;
                //建立父子视图关系
                finishAddingViewControllers();
            }];
            
        }
        else
            finishAddingViewControllers();
    }
    else //如果两个视图控制器一样
    // No animation required.
    {
        finishRemovingViewControllers();//将需要删除的视图控制器删除
        finishAddingViewControllers();//将需要添加的视图控制器添加进来
    }
    
    _viewControllers = viewControllers;
    
    // Update the stack of navigation items for the _navigationBar to
    // reflect the new navigation stack.
    NSMutableArray *newNavigationItemsArray = [NSMutableArray arrayWithCapacity:viewControllers.count];
    for (UIViewController *vc in viewControllers)
        [newNavigationItemsArray addObject:vc.navigationItem];
    // 将给viewControllers数组中的视图控制器 添加到_navigationBar的导航堆栈中。
    [_navigationBar setItems:newNavigationItemsArray animated:animated];
}


//| ----------------------------------------------------------------------------
//! Pushes a view controller onto the receiver’s stack and updates the display.
//push 将viewController压入导航中
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Replace the navigation stack with a new array that has viewController
    // apeneded to it.
    [self setViewControllers:[self.viewControllers arrayByAddingObject:viewController] animated:animated];
}


//| ----------------------------------------------------------------------------
//! Pops view controllers until the specified view controller is at the top of the navigation stack.
//pop到哪个viewController，这个时候要将这个视图控制器以上的控制器全部弹出去
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // Check that viewController is in the navigation stack.
    // 返回当前要pop出来的视图控制器的索引位置
    NSUInteger indexOfViewController = [_viewControllers indexOfObject:viewController];
    if (indexOfViewController == NSNotFound)
        return nil;
    
    NSArray *viewControllersThatWerePopped = [_viewControllers subarrayWithRange:NSMakeRange(indexOfViewController+1, _viewControllers.count - (indexOfViewController+1))];
    NSArray *newViewControllersArray = [_viewControllers subarrayWithRange:NSMakeRange(0, indexOfViewController+1)];
    
    // Replace the navigation stack with a new array containg only the view
    // controllers up to the specified viewController.
    [self setViewControllers:newViewControllersArray animated:YES];
    return viewControllersThatWerePopped;
}

@end
