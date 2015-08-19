//
//  KeyboardViewController.swift
//  NaughtyKeyboard
//
//  Created by Romain Pouclet on 2015-08-10.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

// Native Frameworks
import UIKit

// Shared Proxy
import NaughtyStringsProxy

class KeyboardViewController: UIInputViewController {

    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    let nextKeyboardButton = UIButton(type: .Custom)
    let appConfiguration = AppGroupConfiguration()
  
    var strings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.setTitle("Switch keyboard", forState: .Normal)
        nextKeyboardButton.addTarget(self, action: Selector("didTapNextKeyboardButton"), forControlEvents: .TouchUpInside)
        view.addSubview(nextKeyboardButton)
        
        let topButtonConstraint = NSLayoutConstraint(item: nextKeyboardButton, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0)
        let leftButtonConstraint = NSLayoutConstraint(item: nextKeyboardButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0)
        view.addConstraints([ leftButtonConstraint, topButtonConstraint])

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "StringCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: nextKeyboardButton, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0)
        view.addConstraints([topConstraint, leftConstraint, bottomConstraint, rightConstraint])

        strings = self.loadStrings()
        tableView.reloadData()
    }
    
    func didTapNextKeyboardButton() {
        advanceToNextInputMode()
    }
  
    // MARK: - Internal Helpers
    /**
    Loads the list of «Naughty Strings».
    Depending on wether or not there's a synced file it returns it or the bundled one.
    
    :returns: The list of naughty strings to be used by the keyboard.
  
    @author: @esttorhe
    */
    internal func loadStrings() -> [String] {
      /**
      First check if we have already synced from the remote location.
      If not load the embedded file; else load the remotely fetched one.
      */
      let path : String
      if let _ = self.appConfiguration.userDefaults.objectForKey("etag") {
        path = (self.appConfiguration.appGroupURL?.URLByAppendingPathComponent("blns").URLByAppendingPathExtension("json").path)!
      } else {
        path = NSBundle(forClass: self.dynamicType).pathForResource("blns", ofType: "json")!
      }
      
      // TODO: Is it worth to do error handling on a keyboard extension?
      strings = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path)!, options: NSJSONReadingOptions()) as! [String]
      
      return strings
    }
}

extension KeyboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let string = strings[indexPath.row]
        textDocumentProxy.insertText(string)
        textDocumentProxy.insertText("\n")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StringCell", forIndexPath: indexPath) 
        cell.textLabel?.text = strings[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
}
