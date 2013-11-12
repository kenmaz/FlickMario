//
//  KMMyScene.m
//  FlickMario
//
//  Created by kenmaz on 2013/11/10.
//  Copyright (c) 2013年 kenmaz. All rights reserved.
//

#import "KMMyScene.h"
#import "KMEnemyNode.h"

static const uint32_t marioCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;
static const uint32_t wallCategory = 0x1 << 2;
static const uint32_t goldCategory = 0x1 << 3;

@interface KMMyScene() <SKPhysicsContactDelegate>
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
    self.physicsWorld.contactDelegate = self;

    //start point
    [self addPlateWithSize:CGSizeMake(50, 10) point:CGPointMake(300, self.size.height - 50)];

    for (int i = 0; i < 20; i++) {
        for (int j = 0; j < 2; j++) {
            int width = (arc4random() % (int)50) + 50;
            int x = arc4random() % (int)self.size.width;
            int y = (i * 30) + 30;
            if (y < self.size.height - 50) {
                [self addPlateWithSize:CGSizeMake(width, 3) point:CGPointMake(x, y)];
            }
        }
    }
    
    for (int i = 0; i < 20; i++) {
        [self addGold];
    }
    
    SKSpriteNode* mario = [self createMario];
    mario.position = CGPointMake(self.size.width - 20, self.size.height - 20);
    [self addChild:mario];
    self.mario = mario;
    
    [self runAction:
     [SKAction repeatActionForever:
      [SKAction sequence:@
       [
        [SKAction performSelector:@selector(addEnemy) onTarget:self],
        [SKAction waitForDuration:2.0],
        ]]]];
}

- (SKSpriteNode *)createMario {
    SKSpriteNode* mario = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(10, 20)];
    mario.name = @"mario";
    mario.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:mario.size];
    mario.physicsBody.dynamic = YES;
    mario.physicsBody.allowsRotation = NO;
    mario.physicsBody.mass = 60;
    mario.physicsBody.categoryBitMask = marioCategory;
    mario.physicsBody.collisionBitMask = enemyCategory | goldCategory;
    mario.physicsBody.contactTestBitMask = enemyCategory | goldCategory;
    return mario;
}

- (void)addPlateWithSize:(CGSize)size point:(CGPoint)point {
    SKSpriteNode* block = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:size];
    block.name = @"plate";
    block.position = point;
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
    block.physicsBody.dynamic = NO;
    [self addChild:block];
}

- (void)addEnemy {
    KMEnemyNode* enemy = [[KMEnemyNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(10, 10)];
    enemy.name = @"enemy";
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.collisionBitMask = marioCategory | enemyCategory;
    enemy.physicsBody.contactTestBitMask = marioCategory | enemyCategory;
    
    int x = arc4random() % (int)(self.size.width - 100);
    
    enemy.position = CGPointMake(x, self.frame.size.height - 10);
    [self addChild:enemy];
    
    int r = arc4random() % 2;
    enemy.direction = r == 0 ? KMEnemyDirectionLeft : KMEnemyDirectionRight;
 
    [self resetMoveWithEnemy:enemy];
    
}

- (void)resetMoveWithEnemy:(KMEnemyNode*)enemy {
    float moveX = enemy.direction == KMEnemyDirectionLeft ? -15 : 15;
    SKAction* moveEnemyAction = [SKAction repeatActionForever:[SKAction sequence:@
                                                               [
                                                                [SKAction waitForDuration:0.2],
                                                                [SKAction runBlock:^{
                                                                   [enemy.physicsBody applyForce:CGVectorMake(moveX, 0)];
                                                               }],
                                                                ]]];
    [enemy removeAllActions];
    [enemy runAction:moveEnemyAction];
}

- (void)moveEnemyReverse:(KMEnemyNode*)enemy {
    enemy.direction = enemy.direction == KMEnemyDirectionLeft ? KMEnemyDirectionRight : KMEnemyDirectionLeft;
    [self resetMoveWithEnemy:enemy];
}

- (void)addGold {
    SKSpriteNode* enemy = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(10, 10)];
    enemy.name = @"gold";
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = NO;
    enemy.physicsBody.affectedByGravity = NO;
    enemy.physicsBody.categoryBitMask = goldCategory;
    enemy.physicsBody.collisionBitMask = marioCategory;
    enemy.physicsBody.contactTestBitMask = marioCategory;
    
    int x = arc4random() % (int)self.size.width;
    int y = arc4random() % (int)self.size.height;
    
    enemy.position = CGPointMake(x, y);
    [self addChild:enemy];
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

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *bodyA, *bodyB;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        bodyA = contact.bodyA;
        bodyB = contact.bodyB;
    } else {
        bodyA = contact.bodyB;
        bodyB = contact.bodyA;
    }
    
    if (bodyA.categoryBitMask == marioCategory && bodyB.categoryBitMask == enemyCategory) {
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = @"Game Over";
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:label];
        [self runAction:[SKAction sequence:@
                         [
                          [SKAction waitForDuration:1.0],
                          [SKAction runBlock:^{
                             KMMyScene* scene = [[KMMyScene alloc] initWithSize:self.size];
                             SKTransition* doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
                             [self.view presentScene:scene  transition:doors];
                         }]
                          ]]];
    } else if (bodyA.categoryBitMask == marioCategory && bodyB.categoryBitMask == goldCategory) {
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = @"Good!";
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:label];
        [self runAction:[SKAction sequence:@
                         [
                          [SKAction runBlock:^{
                             [bodyB.node removeFromParent];
                         }],
                          [SKAction waitForDuration:1.0],
                          [SKAction runBlock:^{
                             [label removeFromParent];
                         }]
                         ]]];
        
    } else if (bodyA.categoryBitMask == enemyCategory && bodyB.categoryBitMask == enemyCategory) {
        [self moveEnemyReverse:(KMEnemyNode*)contact.bodyB.node];
    }
}
- (void)didEndContact:(SKPhysicsContact *)contact {
    
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *_node, BOOL *stop) {
        KMEnemyNode* node = (KMEnemyNode*)_node;
        if (node.position.y < 15) {
            [node removeFromParent];
            
        } else if (node.position.x < 20) {
            [node runAction:[SKAction moveByX:10 y:0 duration:1.0] completion:^{
                [self moveEnemyReverse:(KMEnemyNode*)node];
            }];
            
        } else if (self.size.width - 20 < node.position.x) {
            [node runAction:[SKAction moveByX:-10 y:0 duration:1.0] completion:^{
                [self moveEnemyReverse:(KMEnemyNode*)node];
            }];
        }
    }];
}


@end
