//
//  MediaViewCell.swift
//  Broadkazt
//
//  Created by Jeevan Sivagnanasuntharam on 10/10/2017.
//

import Foundation
import UIKit
import Photos
import SDWebImage

class CustomViewFlowLayout : UICollectionViewFlowLayout {
    
    let cellSpacing:CGFloat = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = super.layoutAttributesForElements(in: rect) {
            for (index, attribute) in attributes.enumerated() {
                if index == 0 { continue }
                let prevLayoutAttributes = attributes[index - 1]
                let origin = prevLayoutAttributes.frame.maxX
                if(origin + cellSpacing + attribute.frame.size.width < self.collectionViewContentSize.width) {
                    attribute.frame.origin.x = origin + cellSpacing
                }
            }
            return attributes
        }
        return nil
    }
}

class MediaViewCell: UICollectionViewCell {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblPage: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var bgSeconds: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var constrainImageHeight: NSLayoutConstraint!
    
    var gradientLayer: CAGradientLayer? = nil
    
    @IBOutlet weak var playiconImage: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnClose.layer.cornerRadius = 15.0
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                select();
            } else {
                deselect();
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        func makeDefaultSize(){
            
            self.topConstraint.constant = 20
            self.bottomConstraint.constant = 20
        }
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow{

                let topPadding = window.safeAreaInsets.top
                let bottomPadding = window.safeAreaInsets.bottom
                self.topConstraint.constant = topPadding+20
                self.bottomConstraint.constant = bottomPadding+20
            }else{
                makeDefaultSize()
            }
        }else{
            makeDefaultSize()
        }
       
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
    
        
        
    }
    
    func select(){
//        let overlayImage = UIImage(named:"playicon")
//        let overlayImageView = UIImageView(image:overlayImage)
//        
//        self.imageView.addSubview(overlayImageView);
    }
    
    func deselect(){
//        for view in self.imageView.subviews {
//            view.removeFromSuperview()
//        }
    }
    
    func fillData(thumbUrl: AwsVideo, caseBoolean: Bool, caseUrlStr: String)  {
 
        let placeHolder =  UIImage(named: "placeholder.png")
        self.imageView.sd_setImage(with: URL(string: thumbUrl.thumbnail), placeholderImage:placeHolder);
//        self.imgLogo.sd_setImage(with: URL(string: thumbUrl.logo), placeholderImage:placeHolder);
        
        self.imgLogo.sd_setImage(with:  URL(string:thumbUrl.logo)) { (image, error, cache, url) in
            
            if let image = image{
                
                self.imgLogo.image = image
                let height = self.imgLogo.frame.width/(image.size.width/image.size.height)
                self.constrainImageHeight.constant = height
                
                self.imgLogo.layoutIfNeeded()
            }else{
                self.imgLogo.image = placeHolder
            }
        }

        if(caseBoolean == true){
            self.btnSettings.isHidden = false
        }
        else{
            self.btnSettings.isHidden = true
        }
        
        if(thumbUrl.awsUrl==nil || thumbUrl.awsUrl == "" ) {
            self.playiconImage.isHidden = true;
        }
        else {
            self.playiconImage.isHidden = false;
        }


        
        self.lblTitle.text = thumbUrl.videoName
        self.lblDescription.text = thumbUrl.description
        if thumbUrl.duration % 60 < 10 {
            self.lblDuration.text =  String(format: "%ld:0%ld", thumbUrl.duration/60, thumbUrl.duration % 60)
        }
        else {
            self.lblDuration.text =  String(format: "%ld:%ld", thumbUrl.duration/60, thumbUrl.duration % 60)
        }
                
        if gradientLayer == nil {
            self.createGradientLayer()
        }
    }
    
    func createGradientLayer() {
      
        self.gradientLayer = CAGradientLayer()
        let topColor: CGColor = UIColor.black.withAlphaComponent(0).cgColor
        
        let bottomColor: CGColor = UIColor.black.withAlphaComponent(0.99).cgColor
        
        gradientLayer!.colors = [topColor, bottomColor]
        gradientLayer!.locations = [0.5,1.0]
        
        gradientLayer!.frame = self.bounds
        self.imageView.layer.insertSublayer(gradientLayer!, at: 0)
    }
    
}


