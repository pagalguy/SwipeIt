//
//  LinkListViewController.swift
//  Reddit
//
//  Created by Ivan Bruel on 10/05/16.
//  Copyright © 2016 Faber Ventures. All rights reserved.
//

import UIKit

class LinkListViewController: UIViewController, TitledViewModelViewController,
CloseableViewController {

  // MARK: - IBOutlets
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var listingTypeButton: UIBarButtonItem!

  // MARK: - Public Properties
  var viewModel: LinkListViewModel!

  // MARK: - Private Properties
  private lazy var alertHelper: AlertHelper = {
    return AlertHelper(viewController: self)
  }()

}

// MARK: - Lifecycle
extension LinkListViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCloseButton()
    bindViewModel()
    setupViews()
  }
}

// MARK: - Setup
extension LinkListViewController {

  private func setupViews() {
    setupTableView()
  }

  private func setupTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    tableView.rx_setDelegate(self)
      .addDisposableTo(rx_disposeBag)
    tableView.rx_paginate
      .subscribeNext { [weak self] in
        self?.viewModel.requestLinks()
      }.addDisposableTo(rx_disposeBag)
  }

  private func bindViewModel() {
    bindTitle(viewModel)
    viewModel.requestLinks()
    viewModel.viewModels
      .bindTo(tableView.rx_itemsWithCellFactory) { (tableView, index, viewModel) in
        switch viewModel {
        case let viewModel as LinkItemImageViewModel:
          return self.cellForImageLink(viewModel, index: index)
        case let viewModel as LinkItemSelfPostViewModel:
          return self.cellForSelfPostLink(viewModel, index: index)
        default:
          let cell = tableView.dequeueReusableCell(LinkCell.self, index: index)
          cell.linkViewModel = viewModel
          return cell
        }
      }.addDisposableTo(rx_disposeBag)

    tableView.rx_modelSelected(LinkItemViewModel)
      .subscribeNext { [weak self] viewModel in
        self?.openLinkViewModel(viewModel)
      }.addDisposableTo(rx_disposeBag)

    viewModel.listingTypeName
      .subscribeNext { [weak self] listingTypeName in
      self?.listingTypeButton.title = listingTypeName
    }.addDisposableTo(rx_disposeBag)
  }

  private func updateCellHeight() {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

// MARK: - IBActions
extension LinkListViewController {

  @IBAction private func listingTypeClicked() {
    presentListingTypeActionSheet()
  }
}

// MARK: - Alerts
extension LinkListViewController {

  private func presentListingTypeActionSheet() {
    alertHelper.presentActionSheet(options: ListingType.names) { index in
      guard let index = index else { return }
      if let listingType = ListingType.typeAtIndex(index) {
        self.viewModel.setListingType(listingType)
      } else {
        self.presentListingTypeRangeActionSheet(index)
      }
    }
  }

  private func presentListingTypeRangeActionSheet(listingTypeIndex: Int) {
    alertHelper.presentActionSheet(options: ListingTypeRange.names) { index in
      guard let index = index,
        range = ListingTypeRange.rangeAtIndex(index),
        listingType = ListingType.typeAtIndex(listingTypeIndex, range: range) else {
          return
      }
      self.viewModel.setListingType(listingType)
    }
  }
}

// MARK: - Cells
extension LinkListViewController {

  private func cellForImageLink(viewModel: LinkItemImageViewModel, index: Int) -> LinkImageCell {
    let cell = tableView.dequeueReusableCell(LinkImageCell.self, index: index)
    cell.linkImageViewModel = viewModel
    viewModel.imageSize
      .distinctUntilChanged()
      .skip(1)
      .subscribeNext { [weak self] _ in
        self?.updateCellHeight()
      }.addDisposableTo(cell.rx_reusableDisposeBag)
    return cell
  }

  private func cellForSelfPostLink(viewModel: LinkItemSelfPostViewModel, index: Int)
    -> LinkSelfPostCell {
      let cell = tableView.dequeueReusableCell(LinkSelfPostCell.self, index: index)
      cell.linkSelfPostViewModel = viewModel
      cell.rx_readMore
        .subscribeNext { [weak self] viewModel in
          self?.openLinkViewModel(viewModel)
        }.addDisposableTo(cell.rx_reusableDisposeBag)
      return cell
  }
}

// MARK: - Helpers
extension LinkListViewController {

  private func openLinkViewModel(viewModel: LinkItemViewModel) {
    print("opening \(viewModel)")
  }

  private var visibleImageTableViewCells: [LinkImageCell] {
    return tableView.visibleCells.flatMap { $0 as? LinkImageCell }
  }

  private func stopGIFs() {
    guard !Globals.playGIFScrolling else { return }
    visibleImageTableViewCells.forEach { $0.stopGIF() }
  }

  private func startGIFs() {
    guard Globals.autoPlayGIF else { return }
    visibleImageTableViewCells.forEach { $0.playGIF() }
  }

}

// MARK: - UITableViewDelegate
extension LinkListViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCellEditingStyle {
      return .None
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    stopGIFs()
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    startGIFs()
  }

  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    startGIFs()
  }

  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    startGIFs()
  }
}
