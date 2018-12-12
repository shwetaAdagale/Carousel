//
//  ViewController.swift
//  TestApp
//
//  Created by Shweta Adagale on 17/11/18.
//  Copyright © 2018 Shweta Adagale. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var arrayOfImage : [String] = ["Bahubali","Bindu","Raazi","Padmawati","Genius"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let frameForView = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.size.height / 3))
        //visible part of cell
        let view1 = ViewForCarousel.instantiate(arrayOfImage: arrayOfImage, isCircular: true, sepration: 3.0, visiblePercentageOfPeekingCell : 0.2 , hasFooter: true, frameOfView: frameForView, backGroundColor: .magenta)
        self.view.addSubview(view1)
        
    }
    
}

