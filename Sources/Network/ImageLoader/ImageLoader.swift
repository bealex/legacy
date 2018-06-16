//
// ImageLoader
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public enum ImageLoaderError: Error {
    case http(HttpError)
    case creating
    case unknown(Error?)
}

public protocol ImageLoaderTask {
    var url: URL { get }
    var size: CGSize { get }
    var mode: ResizeMode { get }

    func cancel()
}

public enum ResizeMode {
    case original
    case fit
    case fill
}

public enum ImageType {
    case jpeg
    case png
    case gif

    case unknown

    public static func guess(url: URL) -> ImageType {
        switch url.pathExtension.lowercased() {
            case "jpeg", "jpg":
                return .jpeg
            case "png":
                return .png
            case "gif":
                return .gif
            default:
                return .unknown
        }
    }

    public var utType: String? {
        let hint: String?
        switch self {
            case .jpeg:
                hint = "public.jpeg"
            case .png:
                hint = "public.png"
            case .gif:
                hint = "public.gif"
            case .unknown:
                hint = nil
        }

        return hint
    }
}

public typealias ImageLoaderCompletion = (ImageLoaderTask, Result<(Data, UIImage), ImageLoaderError>) -> Void

public protocol ImageLoader {
    @discardableResult
    func load(
        url: URL,
        size: CGSize,
        mode: ResizeMode,
        imageType: ImageType,
        completion: @escaping ImageLoaderCompletion
    ) -> ImageLoaderTask
}
