//
//  KMMyScene.m
//  FlickMario
//
//  Created by kenmaz on 2013/11/10.
//  Copyright (c) 2013年 kenmaz. All rights reserved.
//

#import "KMMyScene.h"

@interface KMMyScene()
@property BOOL contentsCreated;
@property SKSpriteNode* mario;
@property CGPoint touchStartPt;
@end

@implementation KMMyScene

- (void)didMoveToView:(SKView *)view {
    if (!self.contentsCreated) {
        [self createSceneContents];
        self.contentsCreated = YES;
    }
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    SKSpriteNode* ground = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(self.size.width, 50)];
    ground.position = CGPointMake(CGRectGetMidX(self.frame), 25);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    ground.physicsBody.dynamic = NO;
    [self addChild:ground];

    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(70, 100)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(250, 150)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(300, 200)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(80, 250)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(240, 300)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(50 , 350)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(100, 400)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(200, 450)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(300, 500)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(80, 550)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(240, 600)];
    [self addPlateWithSize:CGSizeMake(100, 10) point:CGPointMake(50 , 650)];
    
    SKSpriteNode* mario = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(15, 30)];
    mario.name = @"mario";
    mario.position = CGPointMake(self.size.width - 50, self.size.height - 50);
    mario.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:mario.size];
    mario.physicsBody.dynamic = YES;
    mario.physicsBody.allowsRotation = NO;
    mario.physicsBody.mass = 60;
    [self addChild:mario];
    self.mario = mario;
}

- (void)addPlateWithSize:(CGSize)size point:(CGPoint)point {
    SKSpriteNode* block = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:size];
    block.position = point;
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.dynamic = NO;
    [self addChild:block];
}

static const float touchSensitivity = 200.0;
static const float adjust = 50;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInNode:self];
    self.touchStartPt = CGPointMake(pt.x - adjust, pt.y);
    //NSLog(@"touch start:%@", NSStringFromCGPoint(self.touchStartPt));
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

//simulator + magic tracpadだとtouchesEndedの呼び出しにdelayがある
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInNode:self];
    pt = CGPointMake(pt.x - adjust, pt.y);
    //NSLog(@"touch end:%@", NSStringFromCGPoint(pt));
 
    CGVector impulse = CGVectorMake((pt.x - self.touchStartPt.x) * touchSensitivity,
                                    (pt.y - self.touchStartPt.y) * touchSensitivity);
    NSLog(@"impulse:%f,%f", impulse.dx, impulse.dy);

    [self.mario.physicsBody applyImpulse:impulse];
}

@end
