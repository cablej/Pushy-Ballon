//
//  Balloon.m
//  Pushy Ballon
//
//  Created by Jack on 7/24/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "Balloon.h"
#import "Constants.h"

static const uint32_t balloonCategory = 0x1 << 0;
static const uint32_t spikeCategory   = 0x1 << 1;

@implementation Balloon

-(instancetype) init {
    if(self = [super initWithImageNamed:@"balloon"]) {
        self.size = CGSizeMake(90, 120);
        self.zRotation = -115;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.friction = 0.0f;
        self.physicsBody.restitution = 1.0f;
        self.physicsBody.linearDamping = 0.0f;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.categoryBitMask = balloonCategory;
        self.physicsBody.contactTestBitMask = spikeCategory;
    }
    
    return self;
}

-(void) push {
    SKAction *move = [SKAction moveByX: 0 y:100 duration:.2];
    [self runAction:move];
    SKAction *shrink = [SKAction scaleBy:1.15 duration:.2];
    [self runAction:shrink];
    //self.size = CGSizeMake(1.03*self.size.width, 1.03*self.size.height);
    //self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
}

@end
