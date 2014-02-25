#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (Blocks)

@property (nonatomic, copy) void (^start)(void);
@property (nonatomic, copy) void (^completion)(BOOL finished);

@end
