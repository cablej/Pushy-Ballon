//
//  PBMyScene.m
//  Pushy Ballon
//
//  Created by Jack on 7/24/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "PBGameScene.h"
#import "Balloon.h"
#import "Constants.h"
#import "PBParallaxScrolling.h"

static const uint32_t balloonCategory = 0x1 << 0;
static const uint32_t spikeCategory   = 0x1 << 1;

@interface PBGameScene()

@property (nonatomic, strong) PBParallaxScrolling * parallaxBackground;

@end

@implementation PBGameScene {
    SKEmitterNode *emitterNode;
    Balloon *balloon;
    
    int metersTraveled;
    SKLabelNode *meterLabel;
    
    BOOL gameHasEnded;
    SKSpriteNode *bird;
    NSArray *birdFlyingFrames;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        NSMutableArray *flyFrames = [NSMutableArray array];
        SKTextureAtlas *birdAnimatedAtlas = [SKTextureAtlas atlasNamed:@"bird"];
        int numImages = (int) birdAnimatedAtlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"bird%d", i];
            SKTexture *temp = [birdAnimatedAtlas textureNamed:textureName];
            [flyFrames addObject:temp];
        }
        birdFlyingFrames = flyFrames;
        SKTexture *temp = birdFlyingFrames[0];
        bird = [SKSpriteNode spriteNodeWithTexture:temp];
        bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:bird];
        [self flyingBird];
        
        
        metersTraveled = 0;
        gameHasEnded = NO;
        
        meterLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Heavy"];
        meterLabel.text = [NSString stringWithFormat:@"%im", metersTraveled];
        meterLabel.fontSize = 36;
        meterLabel.position = CGPointMake(self.size.width / 2.0, self.size.height - 60 - meterLabel.frame.size.height / 2);
        [self addChild:meterLabel];
        self.physicsWorld.contactDelegate = self;
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody = borderBody;
        self.physicsBody.friction = 0.0f;
        
        self.backgroundColor = [SKColor whiteColor];
        balloon = [[Balloon alloc] init];
        balloon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:balloon];
        
        [self addChild:[self loadEmitterNode:@"Air"]];
        
        //[self addSpikes];
        [self moveToLeft];
        
        
        /* Setup your scene here */
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.scaleMode = SKSceneScaleModeAspectFit;
        NSArray * imageNames;
        imageNames= @[@"pForegroundHorizontal", @"pMiddleHorizontal", @"pBackgroundHorizontal"];
        PBParallaxScrolling * parallax = [[PBParallaxScrolling alloc] initWithBackgrounds:imageNames size:size direction:kPBParallaxBackgroundDirectionLeft fastestSpeed:kPBParallaxBackgroundDefaultSpeed andSpeedDecrease:kPBParallaxBackgroundDefaultSpeedDifferential];
        self.parallaxBackground = parallax;
        [self addChild:parallax];

    }
    return self;
}

-(void)flyingBird
{
    //This is our general runAction method to make our bear walk.
    [bird runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:birdFlyingFrames
                                       timePerFrame:0.1f
                                             resize:NO
                                            restore:YES]] withKey:@"bird"];
    return;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self.parallaxBackground update:currentTime];
}

- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitterNode.zRotation = -115;
    return emitterNode;
}

-(void) addSpikes {
    
    float x = 0;
    
    while (true) {
        if(x > self.size.width) break;
        
        SKSpriteNode *spike = [self getSpike];
        spike.position = CGPointMake(x + spike.size.width / 2, spike.size.height / 2);
        
        [self addChild:spike];
        
        SKSpriteNode *spike2 = [self getSpike];
        spike2.zRotation = M_PI;
        spike2.position = CGPointMake(x + spike2.size.width / 2, CGRectGetMaxY(self.frame) - spike.size.height / 2);
        [self addChild:spike2];
        
        x += spike.size.width;
    }
}

-(SKSpriteNode *) getSpike {
    SKSpriteNode *spike = [SKSpriteNode spriteNodeWithImageNamed:@"spikes"];
    float height = 40;
    float scaleFactor = height / spike.size.height;
    spike.size = CGSizeMake(spike.size.width * scaleFactor, height);
    spike.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:spike.frame.size];
    spike.physicsBody.dynamic = NO;
    spike.physicsBody.categoryBitMask = spikeCategory;
    spike.name = @"spike";
    
    return spike;
}

-(void) moveToLeft {
    if(gameHasEnded) return;
    metersTraveled++;
    meterLabel.text = [NSString stringWithFormat:@"%im", metersTraveled];
    
    
    [self enumerateChildNodesWithName: @"spike" usingBlock:^(SKNode *node, BOOL *stop) {
        /*if(node.position.y <= BOTTOM_INDENT + ([UIScreen mainScreen].bounds.size.height - (TOP_INDENT + BOTTOM_INDENT)) / NUM_ROWS) {
         [node removeFromParent];
         }
         
         if([self.bit intersectsNode:node]) {
         
         }*/
        SKAction *move = [SKAction moveByX:-node.frame.size.width y:0 duration:1];
        [node runAction:move];
    }];
    
    SKAction *move = [SKAction moveByX: 0 y:-120 duration:1];
    emitterNode.position = CGPointMake(balloon.position.x -50,  balloon.position.y + 14);
    [emitterNode runAction:move];
    [balloon runAction:move];
    
    SKAction *rotate = [SKAction rotateByAngle:M_PI/2 duration:1];
    [emitterNode runAction:rotate];
    [balloon runAction:rotate];
    
    SKAction *shrink = [SKAction scaleBy:.9 duration:1];
    [balloon runAction:shrink];
    
    [self checkSpikes];
    
    
    SKSpriteNode *spike = [self getSpike];
    spike.position = CGPointMake(CGRectGetMaxX(self.frame) - (int) self.size.width % (int) spike.size.width + spike.size.width, spike.size.height / 2);
    
    [self addChild:spike];
    
    SKSpriteNode *spike2 = [self getSpike];
    spike2.zRotation = M_PI;
    spike2.position = CGPointMake(CGRectGetMaxX(self.frame) - (int) self.size.width % (int) spike.size.width + spike.size.width, CGRectGetMaxY(self.frame) - spike.size.height / 2);
    [self addChild:spike2];
    
    [self performSelector:@selector(moveToLeft) withObject:nil afterDelay:1];
}

-(void) checkSpikes {
    __block SKNode *toRemove;
    [self enumerateChildNodesWithName: @"spike" usingBlock:^(SKNode *node, BOOL *stop) {
        /*if(node.position.y <= BOTTOM_INDENT + ([UIScreen mainScreen].bounds.size.height - (TOP_INDENT + BOTTOM_INDENT)) / NUM_ROWS) {
         [node removeFromParent];
         }
         
         if([self.bit intersectsNode:node]) {
         
         }*/
        if(node.position.x + node.frame.size.width / 2 < 0) {
            toRemove = node;
            return;
        }
        
    }];
    if(toRemove != nil) [toRemove removeFromParent];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    emitterNode.position = CGPointMake(-100, 0);
    [balloon push];
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // 3 react to the contact between ball and bottom
    if (firstBody.categoryBitMask == balloonCategory && secondBody.categoryBitMask == spikeCategory) {
        //TODO: Replace the log statement with display of Game Over Scene
        NSLog(@"Hit spike");
        [self popBalloon];
        [self performSelector:@selector(endGame) withObject:nil afterDelay:1];
    }
}

-(void) popBalloon {
    SKEmitterNode *poppingEmmiter = [self loadEmitterNode:@"BalloonPop"];
    poppingEmmiter.position = balloon.position;
    [self addChild:poppingEmmiter];
    [poppingEmmiter performSelector:@selector(removeFromParent) withObject:nil afterDelay:1];
    [balloon removeFromParent];
}

-(void) endGame {
    
    gameHasEnded = YES;
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if(skView == nil) return;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    SKScene * scene = [PBGameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    // Present the scene.
    [skView presentScene:scene];
}

@end
