//
//  ImgCell.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/20/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit

class ImgCell: UICollectionViewCell {
    let activityIndecator = UIActivityIndicatorView()
    @IBOutlet weak var img: UIImageView!
    func activityIndicator(){
        activityIndecator.style = UIActivityIndicatorView.Style.gray
        activityIndecator.center = self.img.center
        activityIndecator.hidesWhenStopped = true
        activityIndecator.startAnimating()
        self.img.addSubview(activityIndecator)
        self.activityIndecator.startAnimating()
    }

}
