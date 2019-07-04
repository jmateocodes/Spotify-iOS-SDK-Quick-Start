//
//  ViewController.swift
//  Spotify iOS SDK Quick Start
//
//  Created by Johanny Mateo on 7/3/19.
//  Copyright © 2019 Johanny A. Mateo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

var theViewController = ViewController()
let appDelegate = UIApplicationMain.shared.delegate as! AppDelegate
appDelegate.myViewController = theViewController

