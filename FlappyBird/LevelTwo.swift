//
//  LevelTwo.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/18/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import SpriteKit


class LevelTwo: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let totalGroundPieces = 5
        var groundPieces = [SKSpriteNode]()
        
        //Add background sprites
        var bg = SKSpriteNode(imageNamed: "sky")
        bg.size = self.frame.size
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(bg)
        
        var hills = SKSpriteNode(imageNamed: "hills")
        hills.anchorPoint = CGPointMake(0, 0)
        
        let aspectRatio: CGFloat = hills.size.width / hills.size.height
        let randomWidth: CGFloat = DVRandGen.skRand(self.frame.size.width / 2, high: self.frame.size.width)
        hills.size = CGSizeMake(randomWidth, randomWidth * aspectRatio)
        
        hills.position = CGPointMake(0,0)
        
        self.addChild(hills)
        
        //Add ground sprites
        for var x = 0; x < totalGroundPieces; x++
        {
            var sprite = SKSpriteNode(imageNamed: "ground_piece")
            groundPieces.append(sprite)
            
            var wSpacing: CGFloat = sprite.size.width / 2
            var hSpacing: CGFloat = 50
            
            if x == 0
            {
                sprite.position = CGPointMake(wSpacing, hSpacing)
            }
            else
            {
                sprite.position = CGPointMake((wSpacing * 2) + groundPieces[x - 1].position.x,groundPieces[x - 1].position.y)
            }
            
            self.addChild(sprite)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
}
