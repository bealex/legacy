//
// DefaultValueTransformer
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct DefaultValueTransformer<ValueTransformer: Transformer>: Transformer {
    public typealias Source = ValueTransformer.Source?
    public typealias Destination = ValueTransformer.Destination

    private let transformer: ValueTransformer
    private let defaultValue: Destination

    public init(transformer: ValueTransformer, defaultValue: Destination) {
        self.transformer = transformer
        self.defaultValue = defaultValue
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        if let value = value, !(value is NSNull) {
            // swiftlint:disable:next array_init
            return transformer.transform(source: value)
        } else {
            return .success(defaultValue)
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        // swiftlint:disable:next array_init
        transformer.transform(destination: value).map { $0 }
    }
}
