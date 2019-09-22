//
// ColorLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public struct ColorLightTransformer: LightTransformer {
    public typealias T = EEColor

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? String).flatMap(T.from(hex:))
    }

    public func to(any value: T?) -> Any? {
        value?.hexARGB
    }
}
