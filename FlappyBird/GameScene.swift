//
//  GameScene.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/9/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import SpriteKit

class Pipe: SKSpriteNode{
    var isBottom: Bool = false
    var isPointAdded: Bool = false
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: GameViewController!
    
    var mainPipe: Pipe!
    var pipes: [Pipe] = [Pipe]()
    var bird: SKSpriteNode!
    var birdAtlas = SKTextureAtlas(named: "bird")
    var birdFrames = [SKTexture]()
    
    var background1: SKSpriteNode!
    var background2: SKSpriteNode!
    
    var ground1: SKSpriteNode!
    var ground2: SKSpriteNode!
    
    var overlay: SKSpriteNode?
    
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    
    var parScore: Int = 0
    var parTime: Int = 60
    
    var score: Int = 0{
        didSet{
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    var remainingTime: Int = 0{
        didSet{
            let min: Int = self.remainingTime / 60
            let sec: Int = self.remainingTime % 60
            self.timeLabel.text = NSString(format: "Time %02d:%02d", min, sec) as String
        }
    }
    
    var timer: NSTimer?
    
    var space: CGFloat = 120
    
    let birdCategory: UInt32 = 1
    let pipeCategory: UInt32 = 2
    
    var isBirdMoving: Bool = false
    var isBackgroundMoving: Bool = true
    var movingSpeed: CGFloat = 2
    
    var birdAnimation: SKAction!
    
    var touchPrevPosition: CGPoint!
    
    var levelTitle: String = "Level 1"
    var levelSubTitle: String = "Survive 5 minutes"
    
    var hasStarted: Bool = true
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        /*for fontName in UIFont.familyNames(){
            println(fontName)
        }*/
        
        //view.backgroundColor = UIColor.redColor()
        let pipeHeight: CGFloat = (view.bounds.size.height - space) / 2
        mainPipe = Pipe(color: UIColor.blackColor(), size: CGSizeMake(50, pipeHeight))
        mainPipe.anchorPoint = CGPointMake(0, 0)
        //println("\(view.bounds.size.width), \(view.bounds.size.height)")
        
        showLevelBegining()
        
        addGround()
        addBackground()
        birdSetup()
    }
    
    func addBackground(){
        background1 = SKSpriteNode(imageNamed: "l1bg")
        background1.size = view!.bounds.size
        background1.texture?.filteringMode = SKTextureFilteringMode.Nearest
        background1.position.x = view!.bounds.size.width / 2
        background1.position.y = view!.bounds.size.height / 2
        
        background2 = SKSpriteNode(imageNamed: "l1bg")
        background2.size = view!.bounds.size
        background2.texture?.filteringMode = SKTextureFilteringMode.Nearest
        background2.position.x = view!.bounds.size.width * 1.5
        background2.position.y = view!.bounds.size.height / 2
        
        self.addChild(background1)
        self.addChild(background2)
    }
    
    func addGround(){
        ground1 = SKSpriteNode(imageNamed: "Ground")
        ground1.name = "ground"
        ground1.zPosition = 10
        ground1.size.width = view!.bounds.size.width + 5
        ground1.texture?.filteringMode = SKTextureFilteringMode.Nearest
        ground1.position.x = view!.bounds.size.width / 2
        ground1.position.y = 0
        ground1.physicsBody = SKPhysicsBody(texture: ground1.texture, size: ground1.size)
        ground1.physicsBody!.dynamic = false
        
        ground2 = SKSpriteNode(imageNamed: "Ground")
        ground2.name = "ground"
        ground2.zPosition = 10
        ground2.size.width = view!.bounds.size.width
        ground2.texture?.filteringMode = SKTextureFilteringMode.Nearest
        ground2.position.x = view!.bounds.size.width * 1.5
        ground2.position.y = 0
        ground2.physicsBody = SKPhysicsBody(texture: ground2.texture, size: ground2.size)
        ground2.physicsBody!.dynamic = false
        
        self.addChild(ground1)
        self.addChild(ground2)
    }
    
    func birdSetup(){
        
        for(var i = 0; i < 3; i++){
            var textureName = "bird\(i)"
            if i == 0{
                var textureName = "bird"
            }
            var texture = birdAtlas.textureNamed(textureName)
            birdFrames.append(texture)
        }
        
        let frameSize: CGSize = birdFrames[0].size()
        
        bird = SKSpriteNode(texture: birdFrames[0], size: CGSizeMake(frameSize.width/1.75, frameSize.height/1.75))
        bird.name = "bird"
        bird.zRotation = 0
        bird.physicsBody = SKPhysicsBody(texture: bird.texture, size: bird.size)
        //bird = SKShapeNode(circleOfRadius: 15)
        //bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        //bird.fillColor = SKColor.redColor()
        bird.physicsBody!.dynamic = false
        bird.physicsBody!.contactTestBitMask = pipeCategory
        bird.physicsBody!.collisionBitMask = pipeCategory
        
        bird.zPosition = 9
        bird.position = CGPointMake(CGRectGetMidX(view!.frame), CGRectGetMidY(view!.frame))
        
        birdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(birdFrames, timePerFrame: 0.15, resize: false, restore: true))
        bird.runAction(birdAnimation, withKey: "birdAnimation")
        
        self.addChild(bird)
    }
    
    func spawnPipeRow(){
        let offset: CGFloat = DVRandGen.skRand(45, high: 70)
        
        let pipeBot: Pipe = mainPipe.copy() as! Pipe
        let pipeTop: Pipe = mainPipe.copy() as! Pipe
        
        pipeBot.texture = SKTexture(imageNamed: "BotPipe")
        pipeTop.texture = SKTexture(imageNamed: "TopPipe")
        
        pipeBot.texture?.filteringMode = SKTextureFilteringMode.Nearest
        pipeTop.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        let randHeight: CGFloat = DVRandGen.skRand(70, high: (view!.bounds.size.height - space))
        //println("randHeight: \(randHeight)")
        
        let xx: CGFloat = view!.bounds.size.width + offset
        //println("xx: \(xx)")
        //println("offset: \(offset)")
        
        if(randHeight < view!.bounds.size.height - space - 60){
            pipeBot.isBottom = true
            
            pipeBot.size.height = randHeight
            pipeBot.physicsBody = SKPhysicsBody(rectangleOfSize: pipeBot.size, center: CGPointMake(pipeBot.size.width/2, pipeBot.size.height/2))
            pipeBot.physicsBody!.dynamic = false
            pipeBot.physicsBody!.contactTestBitMask = birdCategory
            pipeBot.physicsBody!.collisionBitMask = birdCategory
            
            pipeTop.size.height = view!.bounds.size.height - space - randHeight
            pipeTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTop.size, center: CGPointMake(pipeTop.size.width/2, pipeTop.size.height/2))
            pipeTop.physicsBody!.dynamic = false
            pipeTop.physicsBody!.contactTestBitMask = birdCategory
            pipeTop.physicsBody!.collisionBitMask = birdCategory
            
            self.setPositionRelativeBot(pipeBot, x: xx, y: offset)
            self.setPositionRelativeTop(pipeTop, x: xx, y: offset)
            
            pipes.append(pipeBot)
            pipes.append(pipeTop)
            
            self.addChild(pipeBot)
            self.addChild(pipeTop)
        }else{
            if DVRandGen.skRandBool(){
                pipeBot.isBottom = true
                
                pipeBot.size.height = randHeight
                pipeBot.physicsBody = SKPhysicsBody(rectangleOfSize: pipeBot.size, center: CGPointMake(pipeBot.size.width/2, pipeBot.size.height/2))
                pipeBot.physicsBody!.dynamic = false
                pipeBot.physicsBody!.contactTestBitMask = birdCategory
                pipeBot.physicsBody!.collisionBitMask = birdCategory
                
                self.setPositionRelativeBot(pipeBot, x: xx, y: offset)
                pipes.append(pipeBot)
                self.addChild(pipeBot)
            }else{
                pipeTop.isBottom = true
                
                pipeTop.size.height = randHeight
                pipeTop.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTop.size, center: CGPointMake(pipeTop.size.width/2, pipeTop.size.height/2))
                pipeTop.physicsBody!.dynamic = false
                pipeTop.physicsBody!.contactTestBitMask = birdCategory
                pipeTop.physicsBody!.collisionBitMask = birdCategory
                
                self.setPositionRelativeTop(pipeTop, x: xx, y: offset)
                pipes.append(pipeTop)
                self.addChild(pipeTop)
            }
        }
    }
    
    func setPositionRelativeBot(node: SKSpriteNode, x: CGFloat, y: CGFloat){
        node.position = CGPointMake(x, 0)
    }
    
    func setPositionRelativeTop(node: SKSpriteNode, x: CGFloat, y: CGFloat){
        node.position = CGPointMake(x, view!.bounds.size.height - node.size.height)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !isBirdMoving || !hasStarted{
            for touch in touches{
                if let t: UITouch = touch as? UITouch{
                    let touchLocation = t.locationInNode(self)
                    self.enumerateChildNodesWithName("restartNode", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        if node.containsPoint(touchLocation){
                            self.overlay?.removeFromParent()
                            self.removeLevelBegining()
                            
                            for (index, pipe) in enumerate(self.pipes as [Pipe]){
                                pipe.removeFromParent()
                            }
                            
                            self.pipes.removeAll(keepCapacity: false)
                            self.score = 0
                            self.bird.physicsBody?.dynamic = false
                            self.bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                            self.bird.physicsBody!.velocity = CGVectorMake(0, 175)
                            self.isBirdMoving = true
                            self.isBackgroundMoving = true
                            self.birdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(self.birdFrames, timePerFrame: 0.15, resize: false, restore: true))
                            self.bird.runAction(self.birdAnimation, withKey: "birdAnimation")
                            self.hasStarted = true
                        }
                    })
                    self.enumerateChildNodesWithName("nextLevelNode", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        if node.containsPoint(touchLocation){
                            self.viewController.loadNextLevel()
                        }
                    })
                }
            }
        }
        if hasStarted{
            if(!bird.physicsBody!.dynamic){
                // First Touch
                self.removeLevelBegining()
                self.spawnPipeRow()
                bird.physicsBody!.velocity = CGVectorMake(0, 175)
                isBirdMoving = true
                bird.physicsBody!.dynamic = true
            }else if(isBirdMoving){
                var vel: CGFloat = 200
                if self.view!.bounds.size.height - bird.position.y < 85{
                    vel == 85 - (self.view!.bounds.size.height - bird.position.y)
                }
                bird.physicsBody?.velocity = CGVectorMake(0, vel)
                
                for touch in touches{
                    if let t: UITouch = touch as? UITouch{
                        self.touchPrevPosition = t.locationInView(self.view)
                    }
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if(isBirdMoving && self.touchPrevPosition != nil){
            for touch in touches{
                if let t: UITouch = touch as? UITouch{
                    let location: CGPoint = t.locationInView(self.view)
                    var velY: CGFloat = 50 - 1 * (location.y - self.touchPrevPosition.y)
                    var velX: CGFloat = 50 + abs(location.x - self.touchPrevPosition.x)
                    
                    if(location.x - self.touchPrevPosition.x > 0){
                        bird.physicsBody?.velocity = CGVectorMake(velX, velY)
                    }else{
                        bird.physicsBody?.velocity = CGVectorMake(-velX, velY)
                    }
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if(isBackgroundMoving){
            
            ground1.position.x -= movingSpeed
            ground2.position.x -= movingSpeed
            if(ground1.position.x <= -self.view!.bounds.size.width / 2){
                ground1.position.x = self.view!.bounds.size.width * 1.5
            }
            if(ground2.position.x <= -self.view!.bounds.size.width / 2){
                ground2.position.x = self.view!.bounds.size.width * 1.5
            }
            
            background1.position.x -= movingSpeed / 3
            background2.position.x -= movingSpeed / 3
            if(background1.position.x <= -self.view!.bounds.size.width / 2){
                background1.position.x = self.view!.bounds.size.width * 1.5
            }
            if(background2.position.x <= -self.view!.bounds.size.width / 2){
                background2.position.x = self.view!.bounds.size.width * 1.5
            }
            
            if(isBirdMoving){
                for (index, pipe) in enumerate(pipes as [Pipe]){
                    
                    if pipe.position.x + pipe.size.width < 0{
                        pipe.removeFromParent()
                    }
                    
                    if hasStarted && pipe.position.x + pipe.size.width < bird.position.x && pipe.isBottom && !pipe.isPointAdded{
                        score++
                        pipe.isPointAdded = true
                        if parScore > 0 && score >= parScore{
                            self.showLevelCompleted()
                        }
                    }
                    
                    pipe.position.x -= movingSpeed
                    if index == pipes.count - 1{
                        if(pipe.position.x  < self.view!.bounds.width - pipe.size.width * 2){
                            self.spawnPipeRow()
                        }
                    }
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("bird", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.zRotation = 0
        })
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        hasStarted = false
        if(isBirdMoving){
            self.timer?.invalidate()
            isBackgroundMoving = false
            isBirdMoving = false
            bird.removeActionForKey("birdAnimation")
            for (index, pipe) in enumerate(pipes as [SKSpriteNode]){
                pipe.physicsBody = nil
            }
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue()){
                self.showLevelFailed()
            }
        }else{
            if contact.bodyA?.node!.name == "bird" || contact.bodyB?.node!.name == "ground"{
                bird.physicsBody?.dynamic = false
            }else if contact.bodyB?.node!.name == "bird" || contact.bodyA?.node!.name == "ground"{
                bird.physicsBody?.dynamic = false
            }
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
        }
    }
    
    func showLevelBegining(title: String? = nil, subTitle: String? = nil, y: CGFloat? = 0){
        
        overlay = SKSpriteNode(color: SKColor.blackColor().colorWithAlphaComponent(0.3), size: self.frame.size)
        overlay!.zPosition = 99
        overlay!.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        let titleNode: SKLabelNode = SKLabelNode(fontNamed: "Marker Felt")
        titleNode.fontColor = SKColor.blackColor()
        titleNode.zPosition = 100
        titleNode.name = "titleNode"
        titleNode.text = title != nil ? title!: levelTitle
        titleNode.fontSize = 50
        titleNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + y!)
        
        let titleShadow: SKLabelNode = SKLabelNode(fontNamed: "Marker Felt")
        titleShadow.fontColor = SKColor.whiteColor()
        titleShadow.name = "titleShadow"
        titleShadow.text = titleNode.text
        titleShadow.fontSize = 50
        titleShadow.position = CGPointMake(titleShadow.position.x - 3, titleShadow.position.y - 3)
        
        titleNode.addChild(titleShadow)
        
        if parTime > 0{
            let min: Int = self.parTime / 60
            let sec: Int = self.parTime % 60
            levelSubTitle = NSString(format: "Survive %02d:%02d", min, sec) as String
        }
        if parScore > 0{
            levelSubTitle = "Score \(parScore)"
        }
        if parTime > 0 && parScore > 0{
            let min: Int = self.parTime / 60
            let sec: Int = self.parTime % 60
            levelSubTitle = NSString(format: "Survive %02d:%02d or score %d", min, sec, parScore) as String
        }
        
        let subTitleNode: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy")
        subTitleNode.fontColor = SKColor.blackColor()
        subTitleNode.zPosition = 100
        subTitleNode.name = "subtitleNode"
        subTitleNode.text = subTitle != nil ? subTitle! : levelSubTitle
        subTitleNode.fontSize = 30
        subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), titleNode.position.y - 50)
        
        let subtitleShadow: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy")
        subtitleShadow.fontColor = SKColor.whiteColor()
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        subtitleShadow.fontSize = 30
        subtitleShadow.position = CGPointMake(subtitleShadow.position.x - 1, subtitleShadow.position.y - 1)
        
        subTitleNode.addChild(subtitleShadow)
        
        self.addChild(overlay!)
        self.addChild(titleNode)
        self.addChild(subTitleNode)
    }
    
    func removeLevelBegining(){
        overlay?.removeFromParent()
        self.enumerateChildNodesWithName("titleNode", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        self.enumerateChildNodesWithName("subtitleNode", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("restartNode", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        addScoreLabel()
    }
    
    func addScoreLabel(){
        
        removeScoreLabel()
        
        scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.fontSize = 18
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 100
        scoreLabel.position = CGPointMake(10, self.frame.size.height - 25)
        
        self.addChild(scoreLabel)
        
        if parTime > 0{
            addTimeLabel()
        }
    }
    
    func removeScoreLabel(){
        self.enumerateChildNodesWithName("scoreLabel", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    func addTimeLabel(){
        
        removeTimeLabel()
        
        timeLabel = SKLabelNode(fontNamed: "Noteworthy-Bold")
        timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        timeLabel.name = "timeLabel"
        timeLabel.fontColor = SKColor.whiteColor()
        timeLabel.fontSize = 18
        timeLabel.text = "Time 00:00"
        timeLabel.zPosition = 100
        timeLabel.position = CGPointMake(self.frame.size.width - 10, self.frame.size.height - 25)
        
        self.addChild(timeLabel)
        
        remainingTime = parTime
    
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
    }
    
    func removeTimeLabel(){
        timer?.invalidate()
        self.enumerateChildNodesWithName("timeLabel", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    // MARK: - timerTick
    func timerTick(timer: NSTimer){
        remainingTime--
        if remainingTime <= 0{
            showLevelCompleted()
            self.timer?.invalidate()
        }
    }
    
    func showLevelFailed(){
        showLevelBegining(title: "\(levelTitle) failed", subTitle: "")
        
        let subTitleNode: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy-Bold")
        subTitleNode.fontColor = SKColor.blackColor()
        subTitleNode.zPosition = 100
        subTitleNode.name = "restartNode"
        subTitleNode.text = "Restart"
        subTitleNode.fontSize = 30
        subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), 100)
        
        let subtitleShadow: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy-Bold")
        subtitleShadow.fontColor = SKColor.greenColor()
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        subtitleShadow.fontSize = 30
        subtitleShadow.position = CGPointMake(subtitleShadow.position.x - 2, subtitleShadow.position.y - 2)
        
        subTitleNode.addChild(subtitleShadow)
        
        self.addChild(subTitleNode)
    }
    
    func showLevelCompleted(){
        self.timer?.invalidate()
        bird.physicsBody!.dynamic = false
        hasStarted = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue()){
            self.showLevelBegining(title: "\(self.levelTitle) completed", subTitle: "Score: \(self.score)", y: 50)
            
            let subtitleNode: SKLabelNode = self.childNodeWithName("subtitleNode") as! SKLabelNode
            
            let subTitleNode: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy-Bold")
            subTitleNode.fontColor = SKColor.redColor()
            subTitleNode.zPosition = 100
            subTitleNode.name = "nextLevelNode"
            subTitleNode.text = "Play Next"
            subTitleNode.fontSize = 40
            subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), subtitleNode.position.y - 50)
            
            let subtitleShadow: SKLabelNode = SKLabelNode(fontNamed: "Noteworthy-Bold")
            subtitleShadow.fontColor = SKColor.greenColor()
            subtitleShadow.name = "subtitleShadow"
            subtitleShadow.text = subTitleNode.text
            subtitleShadow.fontSize = 40
            subtitleShadow.position = CGPointMake(subtitleShadow.position.x - 2, subtitleShadow.position.y - 2)
            
            subTitleNode.addChild(subtitleShadow)
            
            self.addChild(subTitleNode)
        }
    }
}
