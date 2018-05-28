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

    public func prerenderedImage() -> UIImage {
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

    static public func prerenderedFrom(data: Data, imageType: ImageType, size: CGSize? = nil, withAlpha: Bool = true) -> UIImage? {
        let unsafeData: UnsafePointer<UInt8> = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        guard let cfData = CFDataCreateWithBytesNoCopy(nil, unsafeData, data.count, kCFAllocatorNull) else { return nil }
        guard let dataProvider = CGDataProvider(data: cfData) else { return nil }

        let intent = CGColorRenderingIntent.defaultIntent
        let decodedImage: CGImage? = imageType == .jpeg
            ? CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: intent)
            : CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: intent)

        guard let image = decodedImage else { return UIImage(data: data) }

        let width: CGFloat = floor(min(size?.width ?? CGFloat(image.width), CGFloat(image.width)))
        let height: CGFloat = floor(min(size?.height ?? CGFloat(image.height), CGFloat(image.height)))

        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.prefersExtendedRange = true
            if !withAlpha {
                format.opaque = true
            }
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
            return renderer.image { context in
                let halfWidth = CGFloat(width) / 2
                let halfHeight = CGFloat(height) / 2

                context.cgContext.translateBy(x: halfWidth, y: halfHeight)
                context.cgContext.scaleBy(x: 1, y: -1)
                context.cgContext.translateBy(x: -halfWidth, y: -halfHeight)
                context.cgContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            guard let colourSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }

            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            let imageContext = CGContext(
                data: nil,
                width: Int(ceil(width)), height: Int(ceil(height)),
                bitsPerComponent: 8, bytesPerRow: Int(ceil(width) * 4),
                space: colourSpace, bitmapInfo: bitmapInfo
            )
            guard let context = imageContext else { return nil }

            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

            return context.makeImage().map(UIImage.init(cgImage:))
        }
    }

    private var hasAlpha: Bool {
        guard let cgImage = cgImage else { return false }

        let alpha = cgImage.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
}
