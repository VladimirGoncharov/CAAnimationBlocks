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
