//
//  ViewController.swift
//  NaughtyStrings
//
//  Created by Romain Pouclet on 2015-08-10.
//  Copyright (c) 2015 Perfectly-Cooked. All rights reserved.
//

// Native Frameworks
import UIKit

// Shared Proxy
import NaughtyStringsProxy

class ViewController: UIViewController {
  
    // MARK: Type Alias
    /// Completion handler for asynchronous calls
    typealias CompletionHandler = (succeeded: Bool, error: ErrorType?) -> ()

    // MARK: Properties
  
    @IBOutlet weak var descriptionContainer: UITextView!
    @IBOutlet weak var lastSyncedLabel: UILabel!
  
    /// Source URL of the «Big List Naughty of Naughty Strings» on Github
    internal let stringsURL = "https://raw.githubusercontent.com/minimaxir/big-list-of-naughty-strings/master/blns.json"
  
    /// The AppGroup configuration object
    let appConfiguration = AppGroupConfiguration()
  
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("explaination", ofType: "html")!
        let data = NSData(contentsOfFile: path)!
        let text = try! NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
        text.setAttributes([NSFontAttributeName: UIFont.systemFontOfSize(20)], range: NSMakeRange(0, text.length))
        descriptionContainer.attributedText = text
      
        if let lastUpdate = self.appConfiguration.sharedUserDefaults.objectForKey("lastUpdate") as? NSDate {
          self.lastSyncedLabel.text = "Last updated: \(lastUpdate)"
        }
    }

    // MARK: Events
  
    @IBAction func syncTouched(sender: UIButton) {
        sender.setTitle("Checking for new version…", forState: .Normal)
        self.checkNewVersionAvailable { [unowned self, unowned sender]
            (suceeded, error) in
            if suceeded == true {
                dispatch_async(dispatch_get_main_queue()) {
                    sender.setTitle("Downloading latest version", forState: .Normal)
                }
                
                self.retrieveStrings { (getResult, getResultError) in
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
  
    @author: @esttorhe
    */
    internal func checkNewVersionAvailable(completionHandler: CompletionHandler) -> () {
        // First check if there's a previous etag saved.
        // If there isn't 1 we can safely assume this is first launch and we need to check.
        let ud = self.appConfiguration.sharedUserDefaults
        guard let lastETag = ud.stringForKey("etag") else {
            completionHandler(succeeded: true, error: nil)
          
            return
        }
        
        // Lets make a HEAD request to check for latest etag
        let naughtyStringsURL = NSURL(string: self.stringsURL)!
        let request = NSMutableURLRequest(URL: naughtyStringsURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "HEAD"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, resp, error) in
            guard let response = resp as? NSHTTPURLResponse else { return }
            guard let eTag = response.allHeaderFields["Etag"] as? String else { return }
            
            completionHandler(succeeded: eTag != lastETag, error: nil)
        }
        task.resume()
    }
  
    /**
    Downloads the latest version of the Naughty Strings List and saves it to disk
    
    :param: completionHandler Closure callback notifying the result of the operation.
  
    @author: @esttorhe
    */
    internal func retrieveStrings(completionHandler:CompletionHandler) -> () {
        let ud = self.appConfiguration.sharedUserDefaults
        
        // Request the actual file now that we know there's a newer version
        let naughtyStringsURL = NSURL(string: self.stringsURL)!
        let request = NSMutableURLRequest(URL: naughtyStringsURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, resp, error) in
            var flag = false
            var err: ErrorType? = nil
            
            // Convert the received data and check that everything came back correctly.
            guard let strings = NSString(data: data!, encoding: NSUTF8StringEncoding),
                let response = resp as? NSHTTPURLResponse,
                let eTag = response.allHeaderFields["Etag"] as? String else {
                  completionHandler(succeeded: flag, error: err)
                    
                  return
            }
            
            // Update our «tracking flags»
            ud.setObject(eTag, forKey: "etag")
            ud.setObject(NSDate(), forKey: "lastUpdate")
            ud.synchronize()
            
            /// Reads the prefix from the running bundle.
            if let groupURL = self.appConfiguration.appGroupURL {
                do {
                    try strings.writeToURL(groupURL.URLByAppendingPathComponent("blns").URLByAppendingPathExtension("json"), atomically: true, encoding: NSUTF8StringEncoding)
                    flag = true
                } catch { err = error }
            }
            
            completionHandler(succeeded: flag, error: error)
        }
        task.resume()
    }
}

