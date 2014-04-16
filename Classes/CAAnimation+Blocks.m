#import "CAAnimation+Blocks.h"
#import <objc/runtime.h>

#pragma mark -
#pragma mark - CAAnimationDelegate

@interface CAAnimationDelegate : NSObject

@property (nonatomic, copy) void (^completion)(BOOL);
@property (nonatomic, copy) void (^start)(void);

- (void)animationDidStart:(CAAnimation *)anim;
- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag;

@end

@implementation CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.start)
        self.start();
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag
{
    if (self.completion)
        self.completion(flag);
}

@end

#pragma mark -
#pragma mark - CAAnimation

@interface CAAnimation (BlocksPrivate)

@property (nonatomic, strong, readonly) CAAnimationDelegate *animationDelegate;

@end

@implementation CAAnimation (Blocks)

#pragma mark - private

- (CAAnimationDelegate *)animationDelegate
{
    CAAnimationDelegate *animationDelegate  = objc_getAssociatedObject(self, @selector(animationDelegate));
    if (!animationDelegate)
    {
        animationDelegate                   = [CAAnimationDelegate new];
        
        self.delegate                       = animationDelegate;
        objc_setAssociatedObject(self, @selector(animationDelegate), animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return animationDelegate;
}

#pragma mark - accessory

- (void)setCompletion:(void (^)(BOOL))completion
{
    self.animationDelegate.completion       = completion;
}

- (void (^)(BOOL))completion
{
    return self.animationDelegate.completion;
}

- (void)setStart:(void (^)(void))start
{
    self.animationDelegate.start            = start;
}

- (void (^)(void))start
{
    return self.animationDelegate.start;
}

@end


NSString *const UIViewAnimationTypeBounce       = @"__UIViewAnimationTypeBounce__";
NSString *const UIViewAnimationTypeWiggle       = @"__UIViewAnimationTypeWiggle__";

@implementation CALayer (ANIMATIONS)

- (BOOL)animationEnabled:(NSString *)animation
{
    return ([self animationForKey:animation] != nil);
}

- (void)animationPerform:(NSString *)animation
              completion:(void(^)(BOOL))completion
{
    if ([self animationEnabled:animation])
    {
#if DEBUG
        NSLog(@"%s [warning] - animation(%@) is enabled. ignoring...", __func__, animation);
#endif
        if (completion)
        {
            completion(NO);
        }
        
        return;
    }
    
    CAAnimation *performAnimation       = nil;
    performAnimation                    = [self _makeAnimationForKey:animation
                                                          completion:completion];
    if (performAnimation)
    {
        __unsafe_unretained typeof(self) wself                               = self;
        void(^blockAction)() =
        ^{
            [wself addAnimation:performAnimation
                         forKey:animation];
        };
        
        if ([NSThread isMainThread])
        {
            blockAction();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), blockAction);
        }
    }
    else
    {
        if (completion)
        {
#if DEBUG
            NSLog(@"%s [warning] - animation(%@) not found. ignoring...", __func__, animation);
#endif
            completion(NO);
        }
    }
}

- (void)animationCancel:(NSString *)animation
{
    [self removeAnimationForKey:animation];
}

#pragma mark - private

- (CAAnimation *)_makeAnimationForKey:(NSString *)key
                           completion:(void(^)(BOOL))completion
{
    __unsafe_unretained typeof(self) wself                               = self;
    void(^endAnimation)(BOOL) =
    ^(BOOL finished){
        if (!wself)
            return;
        
        [wself animationCancel:key];
        if (completion)
        {
            completion(finished);
        }
    };
    
    CAAnimation *animation          = nil;
    if ([key isEqualToString:UIViewAnimationTypeBounce])
    {
        CAKeyframeAnimation *bounceAnimation   = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
        bounceAnimation.values = @[@1.0, @1.05, @0.95, @1.02, @0.98, @1.0];
        [bounceAnimation setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                              [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]]];
        bounceAnimation.duration                = 1.0f;
        [bounceAnimation setCompletion:endAnimation];
        
        animation                               = bounceAnimation;
    }
    else if ([key isEqualToString:UIViewAnimationTypeWiggle])
    {
        CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.values = @[@0, @(M_PI / 180 * 5), @(M_PI / 180 * -5), @(M_PI / 180 * 2), @(M_PI / 180 * -2), @0];
        [rotationAnimation setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]]];
        rotationAnimation.duration = 1.0f;
        
        [rotationAnimation setCompletion:endAnimation];
        
        animation                               = rotationAnimation;
    }
    
    return animation;
}

@end
