//
// DictionaryEnumTransformer
// Legacy
//
// Created by Alex Babaev on 12 April 2018.
//

import Foundation

public struct DictionaryEnumTransformer<Enum: Hashable, ValueTransformer: Transformer>: Transformer
        where ValueTransformer.Destination: Hashable {
    public typealias Source = ValueTransformer.Source
    public typealias Destination = Enum

    public let valueTransformer: ValueTransformer
    public let enumValueDictionary: [Enum: ValueTransformer.Destination]
    public let valueEnumDictionary: [ValueTransformer.Destination: Enum]

    public init(transformer: ValueTransformer, dictionary: [Enum: ValueTransformer.Destination]) {
        valueTransformer = transformer

        enumValueDictionary = dictionary
        valueEnumDictionary = [ValueTransformer.Destination: Enum](uniqueKeysWithValues: dictionary.map { ($1, $0) })
    }

    public func transform(source value: Source) -> Result<Destination, TransformerError> {
        if let keyResult = valueTransformer.transform(source: value).value, let result = valueEnumDictionary[keyResult] {
            return .success(result)
        } else {
            return .failure(.source)
        }
    }

    public func transform(destination value: Destination) -> Result<Source, TransformerError> {
        enumValueDictionary[value].map { valueTransformer.transform(destination: $0) } ?? .failure(.source)
    }
}
