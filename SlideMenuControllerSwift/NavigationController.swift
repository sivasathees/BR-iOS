//
//  NavigationController.swift
//  Broadkazt
//
//  Created by Rajamohan S, Independent Software Developer on 05/01/19.
//  Copyright (c) 2018 Rajamohan S. All rights reserved.
//
//	See https://rajamohan-s.github.io/ for author information.
//
 

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override var shouldAutorotate: Bool{
        
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        
        return .portrait
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
