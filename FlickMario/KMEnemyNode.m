//
//  KMEnemyNode.m
//  FlickMario
//
//  Created by kenmaz on 2013/11/11.
//  Copyright (c) 2013年 kenmaz. All rights reserved.
//

#import "KMEnemyNode.h"

static const int kEnemyAliveTime = 30;

@interface KMEnemyNode()
@property BOOL countDown;
@end

@implementation KMEnemyNode

- (void)checkALiveWithCurrentTime:(NSTimeInterval)currentTime {
    if (self.countDown) {
        return;
    }
    
    if (self.birthTime == 0) {
        self.birthTime = currentTime;
        return;
    }
    
    NSTimeInterval elapse = currentTime - self.birthTime;
    if (elapse > kEnemyAliveTime) {
        SKAction *blink = [SKAction repeatAction:
                              [SKAction sequence:@
                               [
                                [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.25],
                                [SKAction colorizeWithColor:[SKColor blackColor] colorBlendFactor:1.0 duration:0.25],
                                ]] count:10];
        SKAction* remove = [SKAction runBlock:^{
            [self removeFromParent];
        }];
        
        SKAction* seq = [SKAction sequence:@[blink, remove]];
        
        [self runAction:seq];
        self.countDown = YES;
    }
}

@end
