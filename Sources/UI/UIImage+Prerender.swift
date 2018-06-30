//
// UIImage (Prerender)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public extension UIImage {
    public func prerender() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0)
        draw(at: .zero)
        UIGraphicsEndImageContext()
    }

    public func prerendered() -> UIImage {
        let width = size.width
        let height = size.height

        if #available(iOS 10.0, *) {
            guard let cgImage = cgImage else { return self }

            let format = UIGraphicsImageRendererFormat()
            format.prefersExtendedRange = true
            format.opaque = !hasAlpha
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { context in
                let halfWidth = CGFloat(width) / 2
                let halfHeight = CGFloat(height) / 2

                context.cgContext.translateBy(x: halfWidth, y: halfHeight)
                context.cgContext.scaleBy(x: 1, y: -1)
                context.cgContext.translateBy(x: -halfWidth, y: -halfHeight)
                context.cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                fatalError("Cannot get image from context for prerender.")
            }
            UIGraphicsEndImageContext()
            return image
        }
    }

    static public func thumbnail(data: Data, imageType: ImageType = .unknown, pixelSize: CGSize? = nil) -> UIImage? {
        var options: [CFString: Any] = [ kCGImageSourceShouldCache: false ]
        if let hint = imageType.utType {
            options[kCGImageSourceTypeIdentifierHint] = hint
        }

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else { return nil }

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldAllowFloat: true,
            kCGImageSourceThumbnailMaxPixelSize: pixelSize.map { max($0.width, $0.height) } ?? 2048
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    static public func thumbnail(url: URL, pixelSize: CGSize? = nil) -> UIImage? {
        let options: [CFString: Any] = [ kCGImageSourceShouldCache: false ]
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, options as CFDictionary) else { return nil }

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldAllowFloat: true,
            kCGImageSourceThumbnailMaxPixelSize: pixelSize.map { max($0.width, $0.height) } ?? 2048
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    private var hasAlpha: Bool {
        guard let cgImage = cgImage else { return false }

        let alpha = cgImage.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
}
