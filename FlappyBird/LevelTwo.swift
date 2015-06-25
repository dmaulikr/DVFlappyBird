//
//  LevelTwo.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/18/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import SpriteKit


class LevelTwo: SKScene, SKPhysicsContactDelegate {
    
    var viewController: LevelTwoViewController!
    
    let movingSpeed: CGFloat = 2
    var grounds: [SKSpriteNode] = [SKSpriteNode]()
    var groundWidth: CGFloat!
    
    var hills: [SKSpriteNode] = [SKSpriteNode]()
    
    var bird: SKSpriteNode!
    var birdAtlas = SKTextureAtlas(named: "bird2")
    var birdFrames = [SKTexture]()
    
    var mainPipe: Pipe!
    var pipes: [Pipe] = [Pipe]()
    
    var space: CGFloat = 120
    
    let birdCategory: UInt32 = 1
    let pipeCategory: UInt32 = 2
    
    var birdAnimation: SKAction!
    var touchPrevPosition: CGPoint!
    
    var isBirdMoving: Bool = false
    var isBackgroundMoving: Bool = true
    
    var timer: NSTimer?
    
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
    
    var levelTitle: String = "Level 2"
    var levelSubTitle: String = "Survive 5 minutes"
    
    var hasStarted: Bool = true
    
    // Preloaded Label & font
    var noteworthyLabel: SKLabelNode!
    var noteworthyLabelBold: SKLabelNode!
    var markerLabel: SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, -5.0)
        
        preloadLabelFont()
        
        showLevelBegining()
        
        let pipeHeight: CGFloat = (view.bounds.size.height - space) / 2
        mainPipe = Pipe(color: UIColor.blackColor(), size: CGSizeMake(50, pipeHeight))
        mainPipe.zPosition = DVRandGen.skRand(2, high: 4)
        println(mainPipe.zPosition)
        mainPipe.anchorPoint = CGPointMake(0, 0)
        
        setupScenery()
        setupBird()
    }
    
    func preloadLabelFont(){
        noteworthyLabel = SKLabelNode(fontNamed: "Noteworthy-Light")
        noteworthyLabel.text = "preloadedText"
        noteworthyLabel.fontSize = 30
        
        noteworthyLabelBold = SKLabelNode(fontNamed: "Noteworthy-Bold")
        noteworthyLabelBold.text = "preloadedText"
        noteworthyLabelBold.fontSize = 30
        
        markerLabel = SKLabelNode(fontNamed: "MarkerFelt-Thin")
        markerLabel.text = "preloadedText"
        markerLabel.fontSize = 50
    }
    
    func setupBird(){
        var totalImgs = birdAtlas.textureNames.count
        
        for var x = 1; x < totalImgs; x++ {
            var textureName = "bird-0\(x)"
            var texture = birdAtlas.textureNamed(textureName)
            birdFrames.append(texture)
        }
        
        bird = SKSpriteNode(texture: birdFrames[0], size: CGSizeMake(30, 30 / 1.14))
        bird.name = "bird"
        bird.zRotation = 0
        bird.physicsBody = SKPhysicsBody(texture: bird.texture, size: bird.size)
        bird.physicsBody!.dynamic = false
        bird.physicsBody!.contactTestBitMask = pipeCategory
        bird.physicsBody!.collisionBitMask = pipeCategory
        
        bird.zPosition = 9
        bird.position = CGPointMake(CGRectGetMidX(view!.frame), CGRectGetMidY(view!.frame))
        
        self.addChild(bird)
        
        birdAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(birdFrames, timePerFrame: 0.2, resize: false, restore: true))
        bird.runAction(birdAnimation, withKey: "birdAnimation")
    }
    
    func setupScenery(){
        //Add background sprites
        var bg = SKSpriteNode(imageNamed: "sky")
        bg.size = self.frame.size
        bg.zPosition = 0
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(bg)
        
        addHills(0)
        
        addHills(CGRectGetMidX(self.frame))
        
        setupGround()
    }
    
    func addHills(offset: CGFloat?){
        var hill = SKSpriteNode(imageNamed: "hills")
        hill.name = "hill"
        hill.anchorPoint = CGPointMake(0, 0)
        
        let aspectRatio: CGFloat = hill.size.width / hill.size.height
        let hillWidth: CGFloat = DVRandGen.skRand(self.frame.size.width / 4, high: self.frame.size.width / 2)
        
        var newOffset: CGFloat = DVRandGen.skRand(self.frame.size.width / 8, high: self.frame.size.width / 4)
        
        if offset == nil{
            newOffset = self.frame.size.width + newOffset
        }else{
            newOffset = offset!
        }
        
        hill.size = CGSizeMake(hillWidth, hillWidth * aspectRatio)
        
        hill.position = CGPointMake(newOffset, 0)
        hill.zPosition = 1
        
        //println(hill.position)
        
        hills.append(hill)
        
        self.addChild(hill)
    }
    
    func setupGround(){
        let requiredGround: Int = Int(ceilf(Float(self.frame.size.width) / 256))
        groundWidth = self.frame.size.width / CGFloat(requiredGround)
        
        for i in 0...requiredGround{
            let ground: SKSpriteNode = SKSpriteNode(imageNamed: "ground_piece")
            ground.name = "ground"
            let aspectRatio: CGFloat = ground.size.width / ground.size.height
            ground.anchorPoint = CGPointMake(0, 0)
            
            var groundHeight: CGFloat = groundWidth / aspectRatio
            groundHeight = groundHeight > 50 ? 50 : groundHeight
            
            ground.size = CGSizeMake(groundWidth + movingSpeed * 5, groundHeight)
            
            //println(ground.size)
            ground.position = CGPointMake(CGFloat(i) * groundWidth, 0)
            ground.zPosition = 3
            
            //let label: SKLabelNode = SKLabelNode(text: "ground \(i)")
            //label.position = CGPointMake(groundWidth / 2, groundHeight / 2)
            //ground.addChild(label)
            
            ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size, center: CGPointMake(ground.size.width/2, ground.size.height/2))
            ground.physicsBody!.dynamic = false
            
            grounds.append(ground)
            self.addChild(ground)
        }
    }
    
    func addPipes(){
        let offset: CGFloat = DVRandGen.skRand(45, high: 70)
        
        let pipeBot: Pipe = mainPipe.copy() as! Pipe
        let pipeTop: Pipe = mainPipe.copy() as! Pipe
        
        let imageIndex: Int = Int(arc4random_uniform(3) + 1)
        
        pipeBot.texture = SKTexture(imageNamed: "tiki-bottom-0\(imageIndex)")
        pipeTop.texture = SKTexture(imageNamed: "tiki-top-0\(imageIndex)")
        
        pipeBot.texture?.filteringMode = SKTextureFilteringMode.Nearest
        pipeTop.texture?.filteringMode = SKTextureFilteringMode.Nearest
        
        var randHeight: CGFloat = DVRandGen.skRand(70, high: (view!.bounds.size.height - space))
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
                self.addPipes()
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
            for ground in grounds{
                ground.position.x -= movingSpeed
                if ground.position.x <= -groundWidth{
                    ground.position.x = CGFloat(grounds.count - 1) * groundWidth - movingSpeed
                }
            }
            
            for (index, hill) in enumerate(hills){
                if hill.position.x + hill.size.width < 0{
                    hill.removeFromParent()
                }
                
                hill.position.x -= movingSpeed / 2
                if index == hills.count - 1{
                    if hill.position.x  < self.view!.bounds.width - hill.size.width{
                        self.addHills(nil)
                    }
                }
            }
            
            if isBirdMoving && (bird.position.x + bird.size.width/2 < 0  || bird.position.x - bird.size.width/2 > self.view!.bounds.width || bird.position.y - bird.size.height/2 > self.view!.bounds.height || bird.position.y + bird.size.height/2 < 0){
                hasStarted = false
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
                            self.addPipes()
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
        
        let titleNode: SKLabelNode = markerLabel.copy() as! SKLabelNode
        titleNode.fontColor = SKColor.blackColor()
        titleNode.zPosition = 100
        titleNode.name = "titleNode"
        titleNode.text = title != nil ? title!: levelTitle
        //titleNode.fontSize = 50
        titleNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + y!)
        
        let titleShadow: SKLabelNode = markerLabel.copy() as! SKLabelNode
        titleShadow.fontColor = SKColor.whiteColor()
        titleShadow.name = "titleShadow"
        titleShadow.text = titleNode.text
        //titleShadow.fontSize = 50
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
        
        let subTitleNode: SKLabelNode = noteworthyLabel.copy() as! SKLabelNode
        subTitleNode.fontColor = SKColor.blackColor()
        subTitleNode.zPosition = 100
        subTitleNode.name = "subtitleNode"
        subTitleNode.text = subTitle != nil ? subTitle! : levelSubTitle
        //subTitleNode.fontSize = 30
        subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), titleNode.position.y - 50)
        
        let subtitleShadow: SKLabelNode = noteworthyLabel.copy() as! SKLabelNode
        subtitleShadow.fontColor = SKColor.whiteColor()
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        //subtitleShadow.fontSize = 30
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
        
        scoreLabel = noteworthyLabelBold.copy() as! SKLabelNode
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
        
        timeLabel = noteworthyLabelBold.copy() as! SKLabelNode
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
        
        let subTitleNode: SKLabelNode = noteworthyLabelBold.copy() as! SKLabelNode
        subTitleNode.fontColor = SKColor.blackColor()
        subTitleNode.zPosition = 100
        subTitleNode.name = "restartNode"
        subTitleNode.text = "Restart"
        //subTitleNode.fontSize = 30
        subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), 100)
        
        let subtitleShadow: SKLabelNode = noteworthyLabelBold.copy() as! SKLabelNode
        subtitleShadow.fontColor = SKColor.greenColor()
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        //subtitleShadow.fontSize = 30
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
            
            let subTitleNode: SKLabelNode = self.noteworthyLabelBold.copy() as! SKLabelNode
            subTitleNode.fontColor = SKColor.redColor()
            subTitleNode.zPosition = 100
            subTitleNode.name = "nextLevelNode"
            subTitleNode.text = "Play Next"
            subTitleNode.fontSize = 40
            subTitleNode.position = CGPointMake(CGRectGetMidX(self.frame), subtitleNode.position.y - 50)
            
            let subtitleShadow: SKLabelNode = self.noteworthyLabelBold.copy() as! SKLabelNode
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
