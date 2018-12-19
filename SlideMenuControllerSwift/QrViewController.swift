
import UIKit
import SwiftyJSON
import AVFoundation
import SVProgressHUD

protocol BarcodeDelegate {
    func barcodeReaded(barcode: String)
}

class QrViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegatemenu: LeftMenuProtocol?
    var delegate: BarcodeDelegate?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scannedText: UILabel!
    @IBOutlet weak var qrCodeiMAGE: UIImageView!
    @IBOutlet weak var Navbar: UINavigationBar!
    
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hasInternet"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "noInternet"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hasInternet), name: NSNotification.Name(rawValue: "hasInternet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noInternet), name: NSNotification.Name(rawValue: "noInternet"), object: nil)
        
        
        let navigationItem = UINavigationItem(title: "Title")
        let logo = UIImage(named: "elstupid.png")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView;
        Navbar.items?.append(navigationItem)
        self.setupCamera()
//        delegatemenu?.changeViewController(LeftMenu.go)
//        delegatemenu?.barcodeScanned("BR1995N")
    }
    

    @objc func hasInternet () {
        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    @objc func noInternet () {
        self.captureSession.stopRunning()
        self.showAPIResponseError(message: "You are not connected to internet.")
    }
    
    
    private func setupCamera() {
        
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            cameraView.layer.addSublayer(videoPreviewLayer)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]
        } else {
            print("Could not add metadata output")
        }
        
        self.captureSession.stopRunning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "GoViewController") as! GoViewController
//        newViewController.barcodeScanned("BRLB1998848767NON")
//        newViewController.qrViewController = self;
//        self.present(newViewController, animated: true, completion: nil)
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        self.setNavigationBarItem()

        
        qrCodeiMAGE.isHidden = false;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.reach!.isReachableViaWiFi() || appDelegate.reach!.isReachableViaWWAN() {
            self.hasInternet()
        }
        else {
            self.noInternet()
        }

        super.viewWillAppear(animated)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // This is the delegate'smethod that is called when a code is readed
//
//        for metadata in metadataObjects {
//
//
//            //delegatemenu?.changeViewController(LeftMenu.go)
//            //delegatemenu?.barcodeScanned(code!)
//
//        }
        
        if let metadata  = metadataObjects.first{
            
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            qrCodeiMAGE.isHidden = true;

            guard let code  = readableObject.stringValue else{
                self.captureSession.startRunning()
                return
            }
            
            SVProgressHUD.show()
            
//            self.delegate?.barcodeReaded(barcode: code)
            
            self.captureSession.stopRunning()
            
            func showNoContent(){
                
                let controller = UIAlertController(title: "Alert!", message: "No conent found for this tag", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "CANCEL", style: .default) { (_) in
                    
                    controller.dismiss(animated: true, completion: nil)
                    let nav  = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! UINavigationController
                    let vc = nav.topViewController as! TutorialViewController
                    vc.completion = {
                        
                        self.captureSession.startRunning()
                        
                    }
                    
                    self.present(nav, animated: true, completion: nil)
                }
                
                let tryAgain = UIAlertAction(title: "TRY AGAIN", style: .default) { (_) in
                    
                    self.captureSession.startRunning()
                }
                
                controller.addAction(cancel)
                controller.addAction(tryAgain)
                
                self.present(controller, animated: true, completion: nil)
                

                
            }
            
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
                            showNoContent()
                        }
                    }else{
                        showNoContent()
                    }
             
                }
           
            }


        }
    }
}

extension QrViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}

