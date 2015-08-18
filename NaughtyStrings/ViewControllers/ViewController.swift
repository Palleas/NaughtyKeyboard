//
//  ViewController.swift
//  NaughtyStrings
//
//  Created by Romain Pouclet on 2015-08-10.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

// Native Frameworks
import UIKit

class ViewController: UIViewController {

    // MARK: Properties
  
    @IBOutlet weak var descriptionContainer: UITextView!
    @IBOutlet weak var lastSyncedLabel: UILabel!
    internal let stringsURL = "https://raw.githubusercontent.com/minimaxir/big-list-of-naughty-strings/master/blns.json"
  
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("explaination", ofType: "html")!
        let data = NSData(contentsOfFile: path)!
        let text = try! NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
        text.setAttributes([NSFontAttributeName: UIFont.systemFontOfSize(20)], range: NSMakeRange(0, text.length))
        descriptionContainer.attributedText = text
      
        if let lstUpdate = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdate") as? NSDate {
          self.lastSyncedLabel.text = "Last updated: \(lstUpdate)"
        }
    }

    // MARK: Events
  
    @IBAction func sync_touched(sender: UIButton) {
      sender.setTitle("Checking for new version…", forState: .Normal)
      self.checkNewVersionAvailable { [unowned self, unowned sender]
        result in
        if result == true {
          dispatch_async(dispatch_get_main_queue()) {
            sender.setTitle("Downloading latest version", forState: .Normal)
          }
          
          self.retrieveStrings { getResult in
            dispatch_async(dispatch_get_main_queue()) {
              if getResult == true {
                self.lastSyncedLabel.text = "Last update: now"
                sender.setTitle("Up to date", forState: .Normal)
              }
            }
          }
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            sender.setTitle("Up to date", forState: .Normal)
          }
        }
      }
    }
  
    // MARK: - Internal helpers
  
    /**
    Checks if there's a new version of the Naughty Strings List.
  
    :param: completionHandler Closure callback notifying the result of the operation.
    */
    internal func checkNewVersionAvailable(completionHandler: (result: Bool) -> ()) -> () {
      // First check if there's a previous etag saved.
      // If there isn't 1 we can safely assume this is first launch and we need to check.
      let ud = NSUserDefaults.standardUserDefaults()
      guard let lastETag = ud.stringForKey("etag") else {
        completionHandler(result: true)
        
        return
      }
      
      // Lets make a HEAD request to check for latest etag
      let naughtyStringsURL = NSURL(string: self.stringsURL)!
      let request = NSMutableURLRequest(URL: naughtyStringsURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
      request.HTTPMethod = "HEAD"
      
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, resp, error) in
        guard let response = resp as? NSHTTPURLResponse else { return }
        guard let eTag = response.allHeaderFields["Etag"] as? String else { return }
        
        completionHandler(result: eTag != lastETag)
      }
      task.resume()
    }
  
    /**
    Downloads the latest version of the Naughty Strings List and saves it to disk
    
    :param: completionHandler Closure callback notifying the result of the operation.
    */
    internal func retrieveStrings(completionHandler:(result: Bool) -> ()) -> () {
      let ud = NSUserDefaults.standardUserDefaults()
      
      // Request the actual file now that we know there's a newer version
      let naughtyStringsURL = NSURL(string: self.stringsURL)!
      let request = NSMutableURLRequest(URL: naughtyStringsURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
      request.HTTPMethod = "GET"
      
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, resp, error) in
        // Convert the received data and check that everything came back correctly.
        guard let strings = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String,
          let response = resp as? NSHTTPURLResponse,
          let eTag = response.allHeaderFields["Etag"] as? String else {
            completionHandler(result: false)
              
            return
        }
        
        // Update our «tracking flags»
        ud.setObject(eTag, forKey: "etag")
        ud.setObject(NSDate(), forKey: "lastUpdate")
        ud.synchronize()
        
        // TODO: Save the retrieved file to the shared container
        
        completionHandler(result: true)
      }
      task.resume()
    }
}

