//
// MockConfigurator
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

final class MockConfigurator: Configurator {
    private var tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    private let timeout: TimeInterval = 60
    private let imagesMemoryCapacity: Int = 50 * 1024 * 1024
    private let imagesDiskCapacity: Int = 100 * 1024 * 1024

    private func imagesHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: imagesMemoryCapacity, diskCapacity: imagesDiskCapacity, diskPath: nil)

        let queue = DispatchQueue.global(qos: .default)

        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger)
        return http
    }

    func create() -> DependencyInjectionContainer {
        let container = Odin()

        let logger: Logger = PrintLogger()
        let imagesHttp = self.imagesHttp(logger: logger)

        let imageLoader = HttpImageLoader(http: imagesHttp, completionQueue: DispatchQueue.main)
        let feedService = MockFeedService()

        // Registering protocols resolvers.
        container.register { (object: inout LoggerDependency) in object.logger = logger }
        container.register { (object: inout ImageLoaderDependency) in object.imageLoader = imageLoader }
        container.register { (object: inout FeedServiceDependency) in object.feedService = feedService }
        container.register { [unowned container] (object: inout DependencyContainerDependency) in object.container = container }

        // Registering type resolvers.
        container.register { () -> Logger in logger }
        container.register { () -> ImageLoader in imageLoader }
        container.register { () -> FeedService in feedService }

        return container
    }
}
