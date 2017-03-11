//
//  NavigationViewController.swift
//  FlappyBird
//
//  Created by Moin Uddin on 6/18/15.
//  Copyright (c) 2015 Moin Uddin. All rights reserved.
//

import UIKit

var levelCount: Int = 1

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.viewControllers.last!.supportedInterfaceOrientations
        
    }
    
    override var shouldAutorotate : Bool {
        return self.viewControllers.last!.shouldAutorotate
    }

}
