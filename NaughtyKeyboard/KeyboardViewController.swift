//
//  KeyboardViewController.swift
//  NaughtyKeyboard
//
//  Created by Romain Pouclet on 2015-08-10.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    var strings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "StringCell")
        // TODO: autolayout that shit
        tableView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 375, height: 194))
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        let path = NSBundle(forClass: self.dynamicType).pathForResource("blns", ofType: "json")!
        strings = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path)!, options: NSJSONReadingOptions.allZeros, error: nil) as! [String]
        tableView.reloadData()
    }
}

extension KeyboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let string = strings[indexPath.row]
        (textDocumentProxy as! UIKeyInput).insertText(string)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StringCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = strings[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("Asking for strings count: \(strings.count)")
        return strings.count
    }
}
