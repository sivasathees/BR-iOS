//
//  TutorialViewController.swift
//  Broadkazt
//
//  Created by Rajamohan S, Independent Software Developer on 10/01/18.
//  Copyright (c) 2018 Rajamohan S. All rights reserved.
//
//	See https://rajamohan-s.github.io/ for author information.
//
 

import UIKit

class TutorialViewController: UIViewController {

    public var completion : (()->Void)? = nil

    private var histories = [History]()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HistoryViewController"{
            
            let vc = segue.destination as! HistoryViewController
            vc.histories = self.histories
        }
    }
    
    @IBAction func actionButton(_ sender: Any) {
        
        if self.completion == nil{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.openCameraVC()
        }else{
            
            self.presentingViewController?.dismiss(animated: true, completion: {
                self.completion!()
            })
        }
     
    }
    
    @IBAction func actionHistory(_ sender: Any) {
        
        self.histories = DBController.getAllHistory()
        
        if histories.isEmpty{
            
            let controller = UIAlertController(title: "Scanned History is Empty!", message: nil, preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(okay)
            self.present(controller, animated: true, completion: nil)
            
        }else{
            self.performSegue(withIdentifier: "HistoryViewController", sender: self)
        }
    }


}
