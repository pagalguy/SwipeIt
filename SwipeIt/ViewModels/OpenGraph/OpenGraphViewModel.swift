//
//  OpenGraphViewModel.swift
//  Reddit
//
//  Created by Ivan Bruel on 10/05/16.
//  Copyright © 2016 Faber Ventures. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire
import RxAlamofire

class OpenGraphViewModel: ViewModel {

  fileprivate static let facebookBotUserAgent = "Facebot"

  fileprivate let openGraph: Variable<OpenGraph?> = Variable(nil)
  fileprivate let url: URL
  fileprivate let disposeBag = DisposeBag()

  var imageURL: Observable<NSURL?> {
    return openGraph.asObservable().map { $0?.imageURL }
  }

  var title: Observable<String?> {
    return openGraph.asObservable().map { $0?.title }
  }

  var linkDescription: Observable<String?> {
    return openGraph.asObservable().map { $0?.description }
  }

  var appLink: Observable<NSURL?> {
    return openGraph.asObservable().map { $0?.appLink?.url }
  }

  init(url: URL) {
    self.url = url
  }
}

// MARK: Network
extension OpenGraphViewModel {

  func requestOpenGraph() {
    let headers = ["User-Agent": OpenGraphViewModel.facebookBotUserAgent]
    requestString(Method.GET, url.absoluteString, headers: headers)
      .observeOn(MainScheduler.instance)
      .bindNext { [weak self] (_, html) in
        self?.openGraph.value = OpenGraph(html: html)
      }.addDisposableTo(disposeBag)
  }

}
