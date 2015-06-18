//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/9/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let spriteView: SKView = self.view as! SKView
        spriteView.showsDrawCount = true
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
        //spriteView.showsPhysics = true
    }
    
    override func viewWillAppear(animated: Bool) {
        let scene: GameScene = GameScene()
        scene.backgroundColor = SKColor.whiteColor()
        //hello.size = CGSizeMake(768, 1024)
        scene.size = self.view.bounds.size
        println(scene.size)
        
        let spriteView: SKView = self.view as! SKView
        spriteView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return  UIInterfaceOrientation.LandscapeLeft
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue
    }
}
