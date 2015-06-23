//
//  LevelTwoViewController.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/18/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            println(LevelTwo.self)
            archiver.setClass(LevelTwo.self, forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! LevelTwo
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class LevelTwoViewController: UIViewController {
    
    var scene: LevelTwo!
    
    var parScore: Int = 5
    var parTime: Int = 10
    
    var levelTitle: String = "Level \(levelCount)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spriteView: SKView = self.view as! SKView
        spriteView.showsDrawCount = true
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
        //spriteView.showsPhysics = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let scene: LevelTwo = GameScene.unarchiveFromFile("LevelTwo") as? LevelTwo {
            
            self.scene = scene
            
            scene.parScore = self.parScore
            scene.parTime = self.parTime
            scene.levelTitle = self.levelTitle
            scene.viewController = self
            
            //scene.backgroundColor = SKColor.whiteColor()
            //hello.size = CGSizeMake(768, 1024)
            scene.size = self.view.bounds.size
            println(scene.size)
            
            /* Set the scale mode to scale to fit the window */
            //scene.scaleMode = .AspectFit
            
            let spriteView: SKView = self.view as! SKView
            spriteView.presentScene(scene)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scene.removeAllActions()
        self.scene.removeAllChildren()
        
        let spriteView: SKView = self.view as! SKView
        spriteView.paused = true
        spriteView.presentScene(nil)
        spriteView.removeFromSuperview()
        
        self.scene = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return  UIInterfaceOrientation.LandscapeRight
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue | UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
    // MARK: - loadNextLevel
    func loadNextLevel(){
        levelCount++
        let vc: GameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        var hasParScore: Bool = DVRandGen.skRandBool()
        let hasParTime: Bool = DVRandGen.skRandBool()
        if hasParScore == false && hasParTime == false {
            hasParScore = true
        }
        vc.parScore = hasParScore ? Int(DVRandGen.skRand(5, high: 10)) + levelCount : 0
        vc.parTime = hasParTime ? Int(DVRandGen.skRand(10, high: 20)) + levelCount : 0
        self.navigationController?.setViewControllers([vc], animated: true)
    }
}
