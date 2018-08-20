//
//  UUScrollablesViewProtocol.swift
//  UUScrollablesViewProtocol
//
//  Created by uxiu.me on 2018/8/17.
//  Copyright © 2018年 uxiu.me. All rights reserved.
//

import UIKit

public protocol UUScrollableProtocol: NSObjectProtocol {}
extension UITableView: UUScrollableProtocol {}
extension UICollectionView: UUScrollableProtocol {}

public  protocol UUScrollablesViewProtocol: NSObjectProtocol {}
extension UITableViewCell: UUScrollablesViewProtocol {}
extension UICollectionReusableView: UUScrollablesViewProtocol {}
extension UITableViewHeaderFooterView: UUScrollablesViewProtocol {}

extension UUScrollablesViewProtocol {
    
    private static var selfName: String {
        return "\(self)"
    }
    
    private static var isNibExist: Bool {
        return Bundle.main.path(forResource: selfName, ofType: "nib") == nil ? false : true
    }
    
    private static var instance: Self? {
        return Bundle.main.loadNibNamed(selfName, owner: self, options: nil)?.last as? Self
    }
    
    private static var nib: UINib? {
        return isNibExist ? UINib(nibName: selfName, bundle: nil) : nil
    }
    
    private static func identifier(isForTableView: Bool, at indexPath: IndexPath, reuseAtTheIndexPathOnly: Bool = false) -> String {
        let sectionStr = "_Section\(String(format: "%02ld", indexPath.section))"
        let indexStr = (isForTableView ? "_Row" : "_Item") + String(format: "%03ld", isForTableView ? indexPath.row : indexPath.item)
        return selfName + (reuseAtTheIndexPathOnly ? sectionStr + indexStr : "")
    }
    
    private static func register(in container: UUScrollableProtocol, with reuseIdentifier: String) {
        let isKindofTableView = container.isKind(of: UITableView.self)
        isNibExist ?
            { isKindofTableView ?
                (container as! UITableView).register(nib, forCellReuseIdentifier: reuseIdentifier) :
                (container as! UICollectionView).register(nib, forCellWithReuseIdentifier: reuseIdentifier) }() :
            { isKindofTableView ?
                (container as! UITableView).register(self , forCellReuseIdentifier: reuseIdentifier) :
                (container as! UICollectionView).register(self , forCellWithReuseIdentifier: reuseIdentifier) }()
    }
    
}

extension UUScrollablesViewProtocol where Self: UITableViewHeaderFooterView {

    public static func newAlways() -> Self {
        return isNibExist ? instance! : Self(reuseIdentifier: selfName)
    }
    
    public static func setup(in tableView: UITableView, at section: Int, reuseInTheSectionOnely reusbale: Bool = false) -> Self {
        let reuseIdentifier = selfName + (reusbale ? "Section_\(section)" : "")
        isNibExist ?
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier) :
            tableView.register(self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as! Self
    }

}

extension UUScrollablesViewProtocol where Self: UITableViewCell {
    
    public static func newAlways(_ cellStyle: UITableViewCellStyle = .default) -> Self {
        return isNibExist ? instance! : Self(style: cellStyle, reuseIdentifier: selfName)
    }
    
    public static func setup(in tableView: UITableView, cellStyle: UITableViewCellStyle = .default) -> Self {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: selfName) as? Self else {
            return newAlways(cellStyle)
        }
        return cell
    }
    
    public static func setup(in tableView: UITableView, at indexPath: IndexPath, reuseAtTheIndexPathOnly reusable: Bool = false) -> Self {
        let reuseIdentifier = identifier(isForTableView: true, at: indexPath, reuseAtTheIndexPathOnly: reusable)
        register(in: tableView, with: reuseIdentifier)
        return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Self
    }
    
}

extension UUScrollablesViewProtocol where Self: UICollectionReusableView {
    
    private static var randomIndexPath: IndexPath {
        return IndexPath(item: Int(arc4random() / 2 + arc4random() / 3), section: Int(arc4random() / 2 + arc4random() / 3))
    }
    
    public static func newAlways(_ viewKind: String, in collectionView: UICollectionView) -> Self {
        return setup(viewKind, in: collectionView, at: randomIndexPath, reuseAtTheIndexPathOnly: true)
    }
    
    public static func setup(_ viewKind: String, in collectionView: UICollectionView, at indexPath: IndexPath, reuseAtTheIndexPathOnly reusable: Bool = true) -> Self {
        let reuseIdentifier = identifier(isForTableView: false, at: indexPath, reuseAtTheIndexPathOnly: reusable)
        isNibExist ?
            collectionView.register(nib, forSupplementaryViewOfKind: viewKind, withReuseIdentifier: reuseIdentifier) :
            collectionView.register(self, forSupplementaryViewOfKind: viewKind, withReuseIdentifier: reuseIdentifier)
        return collectionView.dequeueReusableSupplementaryView(ofKind: viewKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! Self
    }
    
}

extension UUScrollablesViewProtocol where Self: UICollectionViewCell {
    
    public static func newAlways(in collectionView: UICollectionView) -> Self {
        return setup(in: collectionView, at: randomIndexPath, reuseAtTheIndexPathOnly: true)
    }
    
    public static func setup(in collectionView: UICollectionView, at indexPath: IndexPath, reuseAtTheIndexPathOnly reusable: Bool = false) -> Self {
        let reuseIdentifier = identifier(isForTableView: true, at: indexPath, reuseAtTheIndexPathOnly: reusable)
        register(in: collectionView, with: reuseIdentifier)
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Self
    }
    
}




