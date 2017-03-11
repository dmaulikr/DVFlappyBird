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
    static func sceneWithClassNamed(className: String, fileNamed fileName: String) -> SKScene? {
        guard let SceneClass = NSClassFromString(className) as? SKScene,
            let scene = SceneClass.init(fileNamed: fileName) else {
                return nil
        }
        
        return scene
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("here")
        if let scene: LevelTwo = GameScene.sceneWithClassNamed(className: "LevelTwo", fileNamed: "LevelTwo") as? LevelTwo {
            print("Here")
            self.scene = scene
            
            scene.parScore = self.parScore
            scene.parTime = self.parTime
            scene.levelTitle = self.levelTitle
            scene.viewController = self
            
            //scene.backgroundColor = SKColor.whiteColor()
            //hello.size = CGSizeMake(768, 1024)
            scene.size = self.view.bounds.size
            print(scene.size)
            
            /* Set the scale mode to scale to fit the window */
            //scene.scaleMode = .AspectFit
            
            let spriteView: SKView = self.view as! SKView
            spriteView.presentScene(scene)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scene.removeAllActions()
        self.scene.removeAllChildren()
        
        let spriteView: SKView = self.view as! SKView
        spriteView.isPaused = true
        spriteView.presentScene(nil)
        spriteView.removeFromSuperview()
        
        self.scene = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return  UIInterfaceOrientation.landscapeRight
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(Int(UIInterfaceOrientationMask.landscapeLeft.rawValue | UIInterfaceOrientationMask.landscapeRight.rawValue)))
    }
    
    // MARK: - loadNextLevel
    func loadNextLevel(){
        levelCount += 1
        let vc: GameViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
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
