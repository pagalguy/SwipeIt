//
//  JSONHelper.swift
//  Reddit
//
//  Created by Ivan Bruel on 05/08/16.
//  Copyright © 2016 Faber Ventures. All rights reserved.
//

class JSONHelper {

  class func flatJSON(_ json: [String: AnyObject?]?) -> [String: AnyObject]? {
    guard let json = json else {
      return nil
    }
    return json.flatMap({ (pair) -> (String, AnyObject)? in
      guard let value = pair.1 else {
        return nil
      }
      return (pair.0, value)
    }).reduce([:], { (dict, pair) -> [String: AnyObject] in
      var dict = dict
      dict[pair.0] = pair.1
      return dict
    })
  }

  class func containsKeys(_ json: [String: AnyObject]?, keys: [String]) -> Bool {
    guard keys.count > 0 else {
      return true
    }

    guard let json = json else {
      return false
    }

    return keys.reduce(true) { $0.0 && json.keys.contains($0.1) }
  }
}
