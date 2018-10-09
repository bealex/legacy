//
// Reusable
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public enum Reusable<CellType> {
    case `class`(id: String)
    case classId
    case nib(id: String, name: String, bundle: Bundle?)

    public var id: String {
        switch self {
            case .class(let id): return id
            case .classId: return String(describing: type(of: CellType.self))
            case .nib(let id, _, _): return id
        }
    }
}

public extension UITableView {
    // Cell
    public func registerReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellReuseIdentifier: id)
            case .classId:
                register(CellType.self, forCellReuseIdentifier: reusable.id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellReuseIdentifier: id)
        }
    }

    public func dequeueReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>) -> CellType {
        let anyCell = dequeueReusableCell(withIdentifier: reusable.id)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    public func dequeueReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        let anyCell = dequeueReusableCell(withIdentifier: reusable.id, for: indexPath)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    // Header/Footer

    public func registerReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forHeaderFooterViewReuseIdentifier: id)
            case .classId:
                register(CellType.self, forHeaderFooterViewReuseIdentifier: reusable.id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forHeaderFooterViewReuseIdentifier: id)
        }
    }

    public func dequeueReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) -> CellType {
        let anyCell = dequeueReusableHeaderFooterView(withIdentifier: reusable.id)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view header/footer type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }
}

public extension UICollectionView {
    public func registerReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellWithReuseIdentifier: id)
            case .classId:
                register(CellType.self, forCellWithReuseIdentifier: reusable.id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellWithReuseIdentifier: id)
            }
    }

    public func registerReusableHeader<CellType: UICollectionReusableView>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: id)
            case .classId:
                register(CellType.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: reusable.id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: id)
            }
    }

    public func dequeueReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        let anyCell = dequeueReusableCell(withReuseIdentifier: reusable.id, for: indexPath)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid collection view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    public func dequeueReusableSupplementaryView<CellType: UICollectionReusableView>(
        _ reusable: Reusable<CellType>,
        indexPath: IndexPath
    ) -> CellType {
        let anyCell = dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: reusable.id,
            for: indexPath
        )
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid collection view supplementary view type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }
}
