//
//  AppGroupConfiguration.swift
//  NaughtyStrings
//
//  Created by Esteban Torres on 18/8/15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

// Native Frameworks
import Foundation

/**
Shared framework that abstracts use of NSUserDefaults and file storage.

@author: @esttorhe
*/
public class AppGroupConfiguration: NSObject {
  /// Internal class that holds access to the basic configuration of the shared code.
  internal class AppConfiguration {
    /// Reads the prefix from the running bundle.
    internal struct Bundle {
      static var prefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AAPLNaughtyStringsBundlePrefix") as! String
    }
    
    /// Appends the required group information to the `Bundle.prefix`
    internal struct ApplicationGroups {
      static let primary = "group.\(Bundle.prefix).Data"
    }
  }
  
  /// The shared `UserDefauls`
  public var userDefaults: NSUserDefaults {
    let myDefaults = NSUserDefaults(suiteName: AppConfiguration.ApplicationGroups.primary)
    
    return myDefaults!
  }
  
  /// `NSURL` pointing to the shared file space.
  public var appGroupURL: NSURL? {
    guard let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.\(AppConfiguration.Bundle.prefix).Data") else {
      return nil
    }

    return groupURL
  }
}