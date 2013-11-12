//
//  KMEnemyNode.h
//  FlickMario
//
//  Created by kenmaz on 2013/11/11.
//  Copyright (c) 2013年 kenmaz. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, KMEnemyDirection){
    KMEnemyDirectionLeft,
    KMEnemyDirectionRight
};

@interface KMEnemyNode : SKSpriteNode
@property KMEnemyDirection direction;
@end
