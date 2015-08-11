//
//  ViewController.swift
//  NaughtyStrings
//
//  Created by Romain Pouclet on 2015-08-10.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var descriptionContainer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("explaination", ofType: "html")!
        let data = NSData(contentsOfFile: path)!
        let text = NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil)!
        text.setAttributes([NSFontAttributeName: UIFont.systemFontOfSize(20)], range: NSMakeRange(0, text.length))
        descriptionContainer.attributedText = text
    }

}

