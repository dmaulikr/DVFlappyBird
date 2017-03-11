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
    
    var timer: Timer?
    
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
    
    // Preloaded Label & font
    var noteworthyLabel: SKLabelNode!
    var noteworthyLabelBold: SKLabelNode!
    var markerLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5.0)
        
        /*for fontName in UIFont.familyNames(){
            println(fontName)
            for name in UIFont.fontNamesForFamilyName(fontName as! String){
                println("   \(name)")
            }
        }*/
        
        //view.backgroundColor = UIColor.redColor()
        let pipeHeight: CGFloat = (view.bounds.size.height - space) / 2
        mainPipe = Pipe(color: UIColor.black, size: CGSize(width: 50, height: pipeHeight))
        mainPipe.anchorPoint = CGPoint(x: 0, y: 0)
        //println("\(view.bounds.size.width), \(view.bounds.size.height)")
        
        preloadLabelFont()
        
        showLevelBegining()
        
        addGround()
        addBackground()
        birdSetup()
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
    
    func addBackground(){
        background1 = SKSpriteNode(imageNamed: "l1bg")
        background1.size = view!.bounds.size
        background1.texture?.filteringMode = SKTextureFilteringMode.nearest
        background1.position.x = view!.bounds.size.width / 2
        background1.position.y = view!.bounds.size.height / 2
        
        background2 = SKSpriteNode(imageNamed: "l1bg")
        background2.size = view!.bounds.size
        background2.texture?.filteringMode = SKTextureFilteringMode.nearest
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
        ground1.texture?.filteringMode = SKTextureFilteringMode.nearest
        ground1.position.x = view!.bounds.size.width / 2
        ground1.position.y = 0
        ground1.physicsBody = SKPhysicsBody(texture: ground1.texture!, size: ground1.size)
        ground1.physicsBody!.isDynamic = false
        
        ground2 = SKSpriteNode(imageNamed: "Ground")
        ground2.name = "ground"
        ground2.zPosition = 10
        ground2.size.width = view!.bounds.size.width
        ground2.texture?.filteringMode = SKTextureFilteringMode.nearest
        ground2.position.x = view!.bounds.size.width * 1.5
        ground2.position.y = 0
        ground2.physicsBody = SKPhysicsBody(texture: ground2.texture!, size: ground2.size)
        ground2.physicsBody!.isDynamic = false
        
        self.addChild(ground1)
        self.addChild(ground2)
    }
    
    func birdSetup(){
        
        for i in 0 ..< 3{
            var textureName = "bird\(i)"
            let texture = birdAtlas.textureNamed(textureName)
            birdFrames.append(texture)
        }
        let frameSize: CGSize = birdFrames[0].size()
        
        bird = SKSpriteNode(texture: birdFrames[0], size: CGSize(width: frameSize.width/2, height: frameSize.height/2))
        bird.name = "bird"
        bird.zRotation = 0
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        //bird = SKShapeNode(circleOfRadius: 15)
        //bird.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        //bird.fillColor = SKColor.redColor()
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = pipeCategory
        bird.physicsBody!.collisionBitMask = pipeCategory
        
        bird.zPosition = 9
        bird.position = CGPoint(x: view!.frame.midX, y: view!.frame.midY)
        
        birdAnimation = SKAction.repeatForever(SKAction.animate(with: birdFrames, timePerFrame: 0.15, resize: false, restore: true))
        bird.run(birdAnimation, withKey: "birdAnimation")
        
        self.addChild(bird)
    }
    
    func spawnPipeRow(){
        let offset: CGFloat = DVRandGen.skRand(45, high: 70)
        
        let pipeBot: Pipe = mainPipe.copy() as! Pipe
        let pipeTop: Pipe = mainPipe.copy() as! Pipe
        
        pipeBot.texture = SKTexture(imageNamed: "BotPipe")
        pipeTop.texture = SKTexture(imageNamed: "TopPipe")
        
        pipeBot.texture?.filteringMode = SKTextureFilteringMode.nearest
        pipeTop.texture?.filteringMode = SKTextureFilteringMode.nearest
        
        let randHeight: CGFloat = DVRandGen.skRand(70, high: (view!.bounds.size.height - space))
        //println("randHeight: \(randHeight)")
        
        let xx: CGFloat = view!.bounds.size.width + offset
        //println("xx: \(xx)")
        //println("offset: \(offset)")
        
        if(randHeight < view!.bounds.size.height - space - 60){
            pipeBot.isBottom = true
            
            pipeBot.size.height = randHeight
            pipeBot.physicsBody = SKPhysicsBody(rectangleOf: pipeBot.size, center: CGPoint(x: pipeBot.size.width/2, y: pipeBot.size.height/2))
            pipeBot.physicsBody!.isDynamic = false
            pipeBot.physicsBody!.contactTestBitMask = birdCategory
            pipeBot.physicsBody!.collisionBitMask = birdCategory
            
            pipeTop.size.height = view!.bounds.size.height - space - randHeight
            pipeTop.physicsBody = SKPhysicsBody(rectangleOf: pipeTop.size, center: CGPoint(x: pipeTop.size.width/2, y: pipeTop.size.height/2))
            pipeTop.physicsBody!.isDynamic = false
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
                pipeBot.physicsBody = SKPhysicsBody(rectangleOf: pipeBot.size, center: CGPoint(x: pipeBot.size.width/2, y: pipeBot.size.height/2))
                pipeBot.physicsBody!.isDynamic = false
                pipeBot.physicsBody!.contactTestBitMask = birdCategory
                pipeBot.physicsBody!.collisionBitMask = birdCategory
                
                self.setPositionRelativeBot(pipeBot, x: xx, y: offset)
                pipes.append(pipeBot)
                self.addChild(pipeBot)
            }else{
                pipeTop.isBottom = true
                
                pipeTop.size.height = randHeight
                pipeTop.physicsBody = SKPhysicsBody(rectangleOf: pipeTop.size, center: CGPoint(x: pipeTop.size.width/2, y: pipeTop.size.height/2))
                pipeTop.physicsBody!.isDynamic = false
                pipeTop.physicsBody!.contactTestBitMask = birdCategory
                pipeTop.physicsBody!.collisionBitMask = birdCategory
                
                self.setPositionRelativeTop(pipeTop, x: xx, y: offset)
                pipes.append(pipeTop)
                self.addChild(pipeTop)
            }
        }
    }
    
    func setPositionRelativeBot(_ node: SKSpriteNode, x: CGFloat, y: CGFloat){
        node.position = CGPoint(x: x, y: 0)
    }
    
    func setPositionRelativeTop(_ node: SKSpriteNode, x: CGFloat, y: CGFloat){
        node.position = CGPoint(x: x, y: view!.bounds.size.height - node.size.height)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isBirdMoving || !hasStarted{
            for touch in touches{
                let touchLocation = touch.location(in: self)
                self.enumerateChildNodes(withName: "restartNode", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if node.contains(touchLocation){
                        self.overlay?.removeFromParent()
                        self.removeLevelBegining()
                        
                        for (_, pipe) in (self.pipes as [Pipe]).enumerated(){
                            pipe.removeFromParent()
                        }
                        
                        self.pipes.removeAll(keepingCapacity: false)
                        self.score = 0
                        self.bird.physicsBody?.isDynamic = false
                        self.bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                        self.bird.physicsBody!.velocity = CGVector(dx: 0, dy: 175)
                        self.isBirdMoving = true
                        self.isBackgroundMoving = true
                        self.birdAnimation = SKAction.repeatForever(SKAction.animate(with: self.birdFrames, timePerFrame: 0.15, resize: false, restore: true))
                        self.bird.run(self.birdAnimation, withKey: "birdAnimation")
                        self.hasStarted = true
                    }
                })
                self.enumerateChildNodes(withName: "nextLevelNode", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if node.contains(touchLocation){
                        self.viewController.loadNextLevel()
                    }
                })
            }
        }
        if hasStarted{
            if(!bird.physicsBody!.isDynamic){
                // First Touch
                self.removeLevelBegining()
                self.spawnPipeRow()
                bird.physicsBody!.velocity = CGVector(dx: 0, dy: 175)
                isBirdMoving = true
                bird.physicsBody!.isDynamic = true
            }else if(isBirdMoving){
                var vel: CGFloat = 200
                if self.view!.bounds.size.height - bird.position.y < 85{
                    vel = 85 - (self.view!.bounds.size.height - bird.position.y)
                }
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: vel)
                
                for touch in touches{
                    self.touchPrevPosition = touch.location(in: self.view)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isBirdMoving && self.touchPrevPosition != nil){
            for touch in touches{
                let location: CGPoint = touch.location(in: self.view)
                let velY: CGFloat = 50 - 1 * (location.y - self.touchPrevPosition.y)
                let velX: CGFloat = 50 + abs(location.x - self.touchPrevPosition.x)
                
                if(location.x - self.touchPrevPosition.x > 0){
                    bird.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
                }else{
                    bird.physicsBody?.velocity = CGVector(dx: -velX, dy: velY)
                }
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
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
            
            if isBirdMoving && (bird.position.x + bird.size.width/2 < 0  || bird.position.x - bird.size.width/2 > self.view!.bounds.width || bird.position.y - bird.size.height/2 > self.view!.bounds.height || bird.position.y + bird.size.height/2 < 0){
                hasStarted = false
                self.timer?.invalidate()
                isBackgroundMoving = false
                isBirdMoving = false
                bird.removeAction(forKey: "birdAnimation")
                for (_, pipe) in (pipes as [SKSpriteNode]).enumerated(){
                    pipe.physicsBody = nil
                }
                bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(500 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)){
                    self.showLevelFailed()
                }
            }
            
            if(isBirdMoving){
                for (index, pipe) in (pipes as [Pipe]).enumerated(){
                    
                    if pipe.position.x + pipe.size.width < 0{
                        pipe.removeFromParent()
                    }
                    
                    if hasStarted && pipe.position.x + pipe.size.width < bird.position.x && pipe.isBottom && !pipe.isPointAdded{
                        score += 1
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
        self.enumerateChildNodes(withName: "bird", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.zRotation = 0
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        hasStarted = false
        if(isBirdMoving){
            self.timer?.invalidate()
            isBackgroundMoving = false
            isBirdMoving = false
            bird.removeAction(forKey: "birdAnimation")
            for (_, pipe) in (pipes as [SKSpriteNode]).enumerated(){
                pipe.physicsBody = nil
            }
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(500 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)){
                self.showLevelFailed()
            }
        }else{
            if contact.bodyA.node!.name == "bird" || contact.bodyB.node!.name == "ground"{
                bird.physicsBody?.isDynamic = false
            }else if contact.bodyB.node!.name == "bird" || contact.bodyA.node!.name == "ground"{
                bird.physicsBody?.isDynamic = false
            }
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
    }
    
    func showLevelBegining(_ title: String? = nil, subTitle: String? = nil, y: CGFloat? = 0){
        
        overlay = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.3), size: self.frame.size)
        overlay!.zPosition = 99
        overlay!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        let titleNode: SKLabelNode = markerLabel.copy() as! SKLabelNode
        titleNode.fontColor = SKColor.black
        titleNode.zPosition = 100
        titleNode.name = "titleNode"
        titleNode.text = title != nil ? title!: levelTitle
        //titleNode.fontSize = 50
        titleNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + y!)
        
        let titleShadow: SKLabelNode = markerLabel.copy() as! SKLabelNode
        titleShadow.fontColor = SKColor.white
        titleShadow.name = "titleShadow"
        titleShadow.text = titleNode.text
        //titleShadow.fontSize = 50
        titleShadow.position = CGPoint(x: titleShadow.position.x - 3, y: titleShadow.position.y - 3)
        
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
        subTitleNode.fontColor = SKColor.black
        subTitleNode.zPosition = 100
        subTitleNode.name = "subtitleNode"
        subTitleNode.text = subTitle != nil ? subTitle! : levelSubTitle
        //subTitleNode.fontSize = 30
        subTitleNode.position = CGPoint(x: self.frame.midX, y: titleNode.position.y - 50)
        
        let subtitleShadow: SKLabelNode = noteworthyLabel.copy() as! SKLabelNode
        subtitleShadow.fontColor = SKColor.white
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        //subtitleShadow.fontSize = 30
        subtitleShadow.position = CGPoint(x: subtitleShadow.position.x - 1, y: subtitleShadow.position.y - 1)
        
        subTitleNode.addChild(subtitleShadow)
        
        self.addChild(overlay!)
        self.addChild(titleNode)
        self.addChild(subTitleNode)
    }
    
    func removeLevelBegining(){
        overlay?.removeFromParent()
        self.enumerateChildNodes(withName: "titleNode", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        self.enumerateChildNodes(withName: "subtitleNode", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodes(withName: "restartNode", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        addScoreLabel()
    }
    
    func addScoreLabel(){
        
        removeScoreLabel()
        
        scoreLabel = noteworthyLabelBold.copy() as! SKLabelNode
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 18
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 100
        scoreLabel.position = CGPoint(x: 10, y: self.frame.size.height - 25)
        
        self.addChild(scoreLabel)
        
        if parTime > 0{
            addTimeLabel()
        }
    }
    
    func removeScoreLabel(){
        self.enumerateChildNodes(withName: "scoreLabel", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    func addTimeLabel(){
        
        removeTimeLabel()
        
        timeLabel = noteworthyLabelBold.copy() as! SKLabelNode
        timeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        timeLabel.name = "timeLabel"
        timeLabel.fontColor = SKColor.white
        timeLabel.fontSize = 18
        timeLabel.text = "Time 00:00"
        timeLabel.zPosition = 100
        timeLabel.position = CGPoint(x: self.frame.size.width - 10, y: self.frame.size.height - 25)
        
        self.addChild(timeLabel)
        
        remainingTime = parTime
    
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameScene.timerTick(_:)), userInfo: nil, repeats: true)
    }
    
    func removeTimeLabel(){
        timer?.invalidate()
        self.enumerateChildNodes(withName: "timeLabel", using: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    // MARK: - timerTick
    func timerTick(_ timer: Timer){
        remainingTime -= 1
        if remainingTime <= 0{
            showLevelCompleted()
            self.timer?.invalidate()
        }
    }
    
    func showLevelFailed(){
        showLevelBegining("\(levelTitle) failed", subTitle: "")
        
        let subTitleNode: SKLabelNode = noteworthyLabelBold.copy() as! SKLabelNode
        subTitleNode.fontColor = SKColor.black
        subTitleNode.zPosition = 100
        subTitleNode.name = "restartNode"
        subTitleNode.text = "Restart"
        //subTitleNode.fontSize = 30
        subTitleNode.position = CGPoint(x: self.frame.midX, y: 100)
        
        let subtitleShadow: SKLabelNode = noteworthyLabelBold.copy() as! SKLabelNode
        subtitleShadow.fontColor = SKColor.green
        subtitleShadow.name = "subtitleShadow"
        subtitleShadow.text = subTitleNode.text
        //subtitleShadow.fontSize = 30
        subtitleShadow.position = CGPoint(x: subtitleShadow.position.x - 2, y: subtitleShadow.position.y - 2)
        
        subTitleNode.addChild(subtitleShadow)
        
        self.addChild(subTitleNode)
    }
    
    func showLevelCompleted(){
        self.timer?.invalidate()
        bird.physicsBody!.isDynamic = false
        hasStarted = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(500 * Int64(NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)){
            self.showLevelBegining("\(self.levelTitle) completed", subTitle: "Score: \(self.score)", y: 50)
            
            let subtitleNode: SKLabelNode = self.childNode(withName: "subtitleNode") as! SKLabelNode
            
            let subTitleNode: SKLabelNode = self.noteworthyLabelBold.copy() as! SKLabelNode
            subTitleNode.fontColor = SKColor.red
            subTitleNode.zPosition = 100
            subTitleNode.name = "nextLevelNode"
            subTitleNode.text = "Play Next"
            subTitleNode.fontSize = 40
            subTitleNode.position = CGPoint(x: self.frame.midX, y: subtitleNode.position.y - 50)
            
            let subtitleShadow: SKLabelNode = self.noteworthyLabelBold.copy() as! SKLabelNode
            subtitleShadow.fontColor = SKColor.green
            subtitleShadow.name = "subtitleShadow"
            subtitleShadow.text = subTitleNode.text
            subtitleShadow.fontSize = 40
            subtitleShadow.position = CGPoint(x: subtitleShadow.position.x - 2, y: subtitleShadow.position.y - 2)
            
            subTitleNode.addChild(subtitleShadow)
            
            self.addChild(subTitleNode)
        }
    }
}
