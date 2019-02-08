//
// UIImage (Color)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public extension UIImage {
    static func from(
        color: UIColor, size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false, scale: CGFloat = 0
    ) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Cannot create image with parameters: " +
                "color: \(color), size: \(size.width)x\(size.height), scale: \(scale), opaque: \(opaque).")
        }
        UIGraphicsEndImageContext()
        return image
    }
}
