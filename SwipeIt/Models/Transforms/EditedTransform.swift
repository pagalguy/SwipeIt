//
//  EditedTransform.swift
//  Reddit
//
//  Created by Ivan Bruel on 07/03/16.
//  Copyright © 2016 Faber Ventures. All rights reserved.
//

import Foundation
import ObjectMapper

class EditedTransform: TransformType {
  typealias Object = Edited
  typealias JSON = AnyObject

  init() {}

  func transformFromJSON(_ value: AnyObject?) -> Object? {
    return Edited.fromValue(value)
  }

  func transformToJSON(_ value: Object?) -> JSON? {
    return value?.value ?? false
  }
}
