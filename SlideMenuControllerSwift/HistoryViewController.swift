//
//  HistoryViewController.swift
//  Broadkazt
//
//  Created by Rajamohan S, Independent Software Developer on 19/12/18.
//  Copyright (c) 2018 Rajamohan S. All rights reserved.
//
//	See https://rajamohan-s.github.io/ for author information.
//
 

import UIKit
import SVProgressHUD
import SDWebImage

class CellHistory:UITableViewCell{
    
    @IBOutlet weak var imageViewThump: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    
    func configure(history:History){
        
        
        self.imageViewThump.sd_setImage(with: URL(string: history.image ?? ""), placeholderImage:UIImage(named: "ic_launcher"), options: .highPriority, completed: nil)
        
        self.labelDate.text = history.dateString
        self.labelTitle.text = history.title
        
    }
    
}

class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var histories = [History]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func actionClearAllHistory(_ sender: UIBarButtonItem) {
        
        
        let controller = UIAlertController(title: "Warning!", message: "Are you sure want to clear all scanning history?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default) { (_) in
            
            DBController.removeAllHistory()
            self.histories.removeAll()
            self.tableView.reloadData()
            self.navigationController?.popViewController(animated: true)
        }
        
        let no = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        
        controller.addAction(yes)
        controller.addAction(no)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.histories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellHistory
        cell.accessoryType = .disclosureIndicator
        cell.configure(history: self.histories[indexPath.row])
        return cell
    }
 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
        let code = self.histories[indexPath.row].code
        
        if (editingStyle == .delete) {
            
            self.histories.remove(at: indexPath.row)
            DBController.removeHistory(with: code)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if self.histories.isEmpty{
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let code = self.histories[indexPath.row].code
        SVProgressHUD.show()
        NetworkManager.sharedInstance.getItemByCode(code) { (json) in
            
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
                
                let success = json["success"].bool;
                
                if (success != nil) {
                    if(success)!{
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "GoViewController") as! GoViewController
                        newViewController.barcodeScanned(code)
                        newViewController.itemFetchedJSON = json
                        self.present(newViewController, animated: true, completion: nil)
                    }else {
                        self.showAPIResponseError(message: "No conent found for this tag")
                    }
                }else{
                    self.showAPIResponseError(message: "No conent found for this tag")
                }
                
            }
            
        }
    }
}
