//
// HttpImageLoader
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class HttpImageLoader: ImageLoader {
    open let http: Http

    private let completionQueue: DispatchQueue

    public init(http: Http, completionQueue: DispatchQueue) {
        self.http = http
        self.completionQueue = completionQueue
    }

    open func load(
        url: URL,
        size: CGSize,
        mode: ResizeMode,
        imageType: ImageType,
        completion: @escaping ImageLoaderCompletion
    ) -> ImageLoaderTask {
        let task = Task(url: url, size: size, mode: mode, type: imageType)

        let asyncCompletion = { (result: Result<(Data, UIImage), ImageLoaderError>) in
            self.completionQueue.async {
                completion(task, result)
                task.httpTask = nil
            }
        }

        let request = http.request(method: .get, url: url, urlParameters: [:], headers: [:], body: nil, bodyStream: nil)
        let httpTask = http.data(request: request) { _, data, error in
            if let error = error {
                asyncCompletion(.failure(.http(error)))
            } else if let data = data, let image = UIImage.prerenderedFrom(data: data, imageType: imageType) {
                asyncCompletion(.success((data, image)))
            } else {
                asyncCompletion(.failure(.creating))
            }
        }
        task.httpTask = httpTask
        httpTask.resume()

        return task
    }

    private class Task: ImageLoaderTask {
        let url: URL
        let size: CGSize
        let mode: ResizeMode
        let type: ImageType

        var httpTask: HttpTask?

        init(url: URL, size: CGSize, mode: ResizeMode, type: ImageType) {
            self.url = url
            self.size = size
            self.mode = mode
            self.type = type
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
