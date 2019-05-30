//
//  AnnotationView.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import UIKit
import SDWebImage

protocol AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}


class AnnotationView: ARAnnotationView {
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var distanceLabel1: UILabel?
    var imageView:UIImageView?
    var btn:UIButton?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        loadUI()
    }
    
    func loadUI() {
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        imageView?.removeFromSuperview()
        distanceLabel1?.removeFromSuperview()
        
        let label = UILabel(frame: CGRect(x: 55, y: 0, width: self.frame.size.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        distanceLabel = UILabel(frame: CGRect(x: 55, y: 30, width: self.frame.size.width, height: 20))
        distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = UIColor.green
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(distanceLabel!)

        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        imageView?.clipsToBounds = true
        imageView?.contentMode = UIViewContentMode.scaleToFill
        
        self.addSubview(imageView!)
        distanceLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
        
        
        let find_place =  annotation as? Place
        if ((find_place?.distanceFromUser)! / 1000) < 500 {
            self.isHidden = false
            if let annotation = annotation as? Place {
                titleLabel?.text = annotation.placeName
                distanceLabel?.text = String(format: "%.2f miles", annotation.distanceFromUser / 1000)
                imageView?.sd_setImage(with: URL(string: annotation.photo as! String), completed: nil)
            }
        } else {
            self.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = CGRect(x: 55, y:0, width: self.frame.size.width, height: 30)
        distanceLabel?.frame = CGRect(x: 55, y: 30, width: self.frame.size.width, height: 20)
        imageView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouch(annotationView: self)
    }
}
