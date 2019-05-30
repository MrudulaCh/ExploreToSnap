//
//  ImageLoadingWithCache.swift
//  ExplorscheDigital
//
//  Created by Mrudula on 5/27/19.
//  Copyright © 2019 Mrudula. All rights reserved.
//


import Foundation
import UIKit
class ImageLoadingWithCache {
    var imageCache = [String:UIImage]()
    
    func getImage(url: String, imageView: UIImageView, defaultImage: String) {
        if let img = imageCache[url] {
            imageView.image = img
        }
        else {
            print("**")
            print(url)
            print("**")
           
            if let urll = URL(string: url) {
                do {
                    let request: NSURLRequest = NSURLRequest(url: NSURL(string:url)! as URL)
                    let mainQueue = OperationQueue.main
                    NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                        if error == nil {
                            let image = UIImage(data: data!)
                            self.imageCache[url] = image
                            DispatchQueue.main.async {
                                () -> Void in
                                imageView.image = image
                            }
                        }
                        else {
                            imageView.image = UIImage(named: defaultImage)
                        }
                    })
                } catch {
                    imageView.image = UIImage(named: defaultImage)
                }
           } else {
                imageView.image = UIImage(named: defaultImage)
            }
           
        }
    }
}

