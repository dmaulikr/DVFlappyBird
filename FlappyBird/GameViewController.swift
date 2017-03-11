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
    
    var scene: GameScene!
    
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
        
        scene = GameScene()
        scene.parScore = self.parScore
        scene.parTime = self.parTime
        scene.levelTitle = self.levelTitle
        scene.viewController = self
        scene.backgroundColor = SKColor.white
        //hello.size = CGSizeMake(768, 1024)
        scene.size = self.view.bounds.size
        print(scene.size)
        
        let spriteView: SKView = self.view as! SKView
        spriteView.presentScene(scene)
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
        let vc: LevelTwoViewController = self.storyboard?.instantiateViewController(withIdentifier: "LevelTwoViewController") as! LevelTwoViewController
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
