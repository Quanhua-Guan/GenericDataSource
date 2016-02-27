//
//  AbstractDataSource.swift
//  GenericDataSource
//
//  Created by Mohamed Afifi on 9/16/15.
//  Copyright © 2016 mohamede1945. All rights reserved.
//

import UIKit

private let sizeSelectors: [Selector] = ["tableView:heightForRowAtIndexPath:", "collectionView:layout:sizeForItemAtIndexPath:"]

public class AbstractDataSource : NSObject, DataSource, UITableViewDataSource, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout {

    public var scrollViewDelegate: UIScrollViewDelegate? = nil

    public weak var ds_reusableViewDelegate: DataSourceReusableViewDelegate? = nil
    
    public override init() {
        let type = AbstractDataSource.self
        guard self.dynamicType != type else {
            fatalError("\(type) instances can not be created; create a subclass instance instead.")
        }
    }

    // MARK: respondsToSelector

    private func scrollViewDelegateCanHandleSelector(selector: Selector) -> Bool {
        if let scrollViewDelegate = scrollViewDelegate where selector.description.hasPrefix("scrollView") && scrollViewDelegate.respondsToSelector(selector) {
            return true
        }
        return false
    }

    public override func respondsToSelector(selector: Selector) -> Bool {

        if sizeSelectors.contains(selector) {
            return ds_shouldConsumeCellSizeDelegateCalls()
        }

        if scrollViewDelegateCanHandleSelector(selector) {
             return true
        }

        return super.respondsToSelector(selector)
    }
    
    public override func forwardingTargetForSelector(selector: Selector) -> AnyObject? {
        if scrollViewDelegateCanHandleSelector(selector) {
            return scrollViewDelegate
        }
        return super.forwardingTargetForSelector(selector)
    }

    // MARK:- DataSource

    // MARK: UITableViewDataSource

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return ds_numberOfSections()
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ds_numberOfItems(inSection: section)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = ds_collectionView(tableView, cellForItemAtIndexPath: indexPath)
        guard let castedCell = cell as? UITableViewCell else {
            fatalError("Couldn't cast cell '\(cell)' to UITableViewCell")
        }
        return castedCell
    }

    // MARK:- UICollectionViewDataSource

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ds_numberOfItems(inSection: section)
    }

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return ds_numberOfSections()
    }

    public func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell: ReusableCell = ds_collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            guard let castedCell = cell as? UICollectionViewCell else {
                fatalError("Couldn't cast cell '\(cell)' to UICollectionViewCell")
            }
            return castedCell
    }

    // MARK:- UITableViewDelegate
    
    // MARK: Selection

    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return ds_collectionView(tableView, shouldHighlightItemAtIndexPath: indexPath)
    }

    public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(tableView, didHighlightItemAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(tableView, didUnhighlightRowAtIndexPath: indexPath)
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(tableView, didSelectItemAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return ds_collectionView(tableView, willSelectItemAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(tableView, didDeselectItemAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return ds_collectionView(tableView, willDeselectItemAtIndexPath: indexPath)
    }
    
    // MARK: Size

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ds_collectionView(tableView, sizeForItemAtIndexPath: indexPath).height
    }

    // MARK:- UICollectionViewDelegate
    
    // MARK: Selection

    public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return ds_collectionView(collectionView, shouldHighlightItemAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(collectionView, didHighlightItemAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(collectionView, didUnhighlightRowAtIndexPath: indexPath)
    }

    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return ds_collectionView(collectionView, willSelectItemAtIndexPath: indexPath) != nil
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        return ds_collectionView(collectionView, didDeselectItemAtIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return ds_collectionView(collectionView, willDeselectItemAtIndexPath: indexPath) != nil
    }

    // MARK: Size

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return ds_collectionView(collectionView, sizeForItemAtIndexPath: indexPath)
    }

    // MARK:- Data Source
    
    public func ds_numberOfSections() -> Int {
        fatalError("\(self): Should be implemented by subclasses")
    }
    
    public func ds_numberOfItems(inSection section: Int) -> Int {
        fatalError("\(self): Should be implemented by subclasses")
    }

    public func ds_collectionView(collectionView: CollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> ReusableCell {
        fatalError("\(self): Should be implemented by subclasses")
    }
    
    public func ds_collectionView(collectionView: CollectionView, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        fatalError("\(self): \(__FUNCTION__) Should be implemented by subclasses")
    }

    public func ds_shouldConsumeCellSizeDelegateCalls() -> Bool {
        return false
    }
    
    public func ds_collectionView(collectionView: CollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    public func ds_collectionView(collectionView: CollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        // does nothing
    }
    
    public func ds_collectionView(collectionView: CollectionView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        // does nothing
    }

    public func ds_collectionView(collectionView: CollectionView, willSelectItemAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    public func ds_collectionView(collectionView: CollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // does nothing
    }
    
    public func ds_collectionView(collectionView: CollectionView, willDeselectItemAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    public func ds_collectionView(collectionView: CollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        // does nothing
    }
}