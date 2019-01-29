//
//  GoViewController.swift
//  SlideMenuControllerSwift
//

import UIKit
import SwiftyJSON
import MobilePlayer
import Photos
import SafariServices
import JGProgressHUD
import AVKit
import AVFoundation

protocol GoProtocol : class {
    func barcodeScanned(_ itemId: String)
}

class GoViewController: UIViewController, GoProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate {
    
    var timer : Timer!
    var timerCount: NSInteger = 0
    var codeScanned : String = ""
    var itemFetchedJSON:JSON!
    
    var webV : UIWebView!;
    var qrViewController: UIViewController!
    @IBOutlet weak var btnClose: UIButton!
    var hud : JGProgressHUD!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = true;

        let logo = UIImage(named: "elstupid.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.navigationController?.isNavigationBarHidden = true

      //self.hud.show(in:self.view)

  
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.itemFetched(json: self.itemFetchedJSON)

        //	UIApplication.shared.isStatusBarHidden = true;
        //self.slideMenuController()?.removeLeftGestures()
        
        
    }
    
    func barcodeScanned(_ itemId: String) {
        
        codeScanned = itemId
        
    }
    
    @IBAction func btnSettingsTapped(_ sender: Any) {
//        self.webV = UIWebView();
//        self.webV.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        webV.delegate = self
//        self.webV.loadRequest(NSURLRequest(url: NSURL(string: self.caseUrl)! as URL) as URLRequest)
//        let url = NSURL (string: self.caseUrl);
//        let requestObj = NSURLRequest(URL: url!);
//        self.webV.loadRequest(requestObj);
        
//        self.view.addSubview(webV)
        
//        let svc = SFSafariViewController(url: URL(string:self.caseUrl)!)
//        self.present(svc, animated: true, completion: nil)
        
        if let url = URL(string:self.caseUrl){
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
       
        DispatchQueue.main.async {
              UIApplication.shared.isStatusBarHidden = false;
        }
         
 
         dismiss(animated: false, completion: nil)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let qrViewController = storyboard.instantiateViewController(withIdentifier: "QrViewController") as! QrViewController
//        qrViewController.delegatemenu = self.slideMenuController()?.leftViewController as! LeftViewController
//        self.qrViewController = UINavigationController(rootViewController: qrViewController)
//        
//        self.slideMenuController()?.changeMainViewController(self.qrViewController, close: true)
//        self.slideMenuController()?.addLeftGestures()
//        if assetArray.count > 0 {
//            let indexPath = NSIndexPath(item: 0, section: 0)
//            self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: false)
//            assetArray.removeAll()
//            self.collectionView.reloadData()
//        }
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var assetArray = [AwsVideo]()
    var cellIdentifier = "MediaViewCell"
    var caseBool = false;
    var caseUrl = "";
    var caseName = "";
    
    
    func itemFetched(json: JSON){
      
        let success = json["success"].bool;
        let data = json["data"];
        
        if (success != nil) {
            if(success)!{
                assetArray = [AwsVideo]();
                caseBool = data["asset"]["case"].bool!
                if(caseBool == true){
                    caseUrl = data["asset"]["caseUrl"].string!
                }
                for (_, subJson) in data["videos"] {
                    if subJson["thumbnail"].string != nil {
                        let awsVideo = AwsVideo(parameter: subJson)
                        let titte = subJson["corporateLogo"].rawString();
                        awsVideo.logo = titte
                        self.assetArray.append(awsVideo)
                    }
                }
            }else {
                
                DispatchQueue.main.async {
                    
                    self.showAPIResponseError(message: "No content found for this tag.");
                    self.btnCloseTapped(self.btnClose)
                }
            }
        }else{
            
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            
        }
        
        if let v = self.assetArray.first{
            
            print("thumpnail is:",v.thumbnail)
            DBController.addHistory(with: self.codeScanned, title:v.videoName,image: v.thumbnail)
        }
        
        DispatchQueue.main.async() {
            self.collectionView.reloadData()
        }
        
        
    }
    
    
    @objc func runTimedCode () {
        
        DispatchQueue.main.async {
            if self.timerCount == 3 {
                self.timer.invalidate()
                self.timer = nil
                self.showAPIResponseError(message: "Server Error. Please try again later.")
                self.timerCount = 0
                self.btnCloseTapped(self.btnClose)
            }
            else {
                if self.codeScanned.length == 0 {
                    
                }
                else {
                    self.barcodeScanned(self.codeScanned)
                }
            }
        }
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        
        return .portrait
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MediaViewCell
        cell.lblPage.text = String(format: "%ld of %ld", indexPath.row + 1,assetArray.count)
        cell.bgSeconds.layer.cornerRadius = 5.0
        let phasset = assetArray[indexPath.row]
        cell.fillData(thumbUrl: phasset,caseBoolean: caseBool,caseUrlStr: caseUrl)
        cell.btnSettings.tag = indexPath.row
        cell.btnSettings.addTarget(self, action: #selector(self.webURL(_:)), for: .touchUpInside)
        cell.playiconImage.tag = indexPath.row
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        
        
        
        //        let collectionViewWidth = self.collectionView.bounds.size.width/2
        let size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height )
        //
        return size
        
    }
    
    @objc private func webURL(_ sender:UIButton){
        
        let video = assetArray[sender.tag]
        
        
        if let url = URL(string:video.webURL){
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    @IBAction func btnPlayTapped(_ sender: UIButton) {
        
        let image = self.assetArray[sender.tag]
        if(image.awsUrl==nil || image.awsUrl == "" ) {
            return;
        }
        let url = URL(string: image.awsUrl)
//        let playerVC = MobilePlayerViewController(contentURL:url! )
//        playerVC.title = image.videoName
//
//        //playerVC.activityItems = [image.awsUrl]
//        presentMoviePlayerViewControllerAnimated(playerVC)

        let player = AVPlayer(url: url!)
        let playerViewController = AVPlayerViewController()
        
        
        
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
    
}
