#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (Blocks)

@property (nonatomic, copy) void (^start)(void);
@property (nonatomic, copy) void (^completion)(BOOL finished);

@end

//completed animated

extern NSString *const UIViewAnimationTypeBounce;
extern NSString *const UIViewAnimationTypeWiggle;

@interface CALayer (ANIMATIONS)

- (BOOL)animationEnabled:(NSString *)animation;
- (void)animationPerform:(NSString *)animation
              completion:(void(^)(BOOL))completion;
- (void)animationCancel:(NSString *)animation;

@end