//
// DefaultValueTransformer
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

// swiftlint:disable:next generic_type_name
public struct ComposedTransformer<SourceTransformer: Transformer, DestinationTransformer: Transformer>: Transformer
    where SourceTransformer.Destination == DestinationTransformer.Source {
    public typealias Source = SourceTransformer.Source
    public typealias Destination = DestinationTransformer.Destination

    public let sourceTransformer: SourceTransformer
    public let destinationTransformer: DestinationTransformer

    public init(sourceTransformer: SourceTransformer, destinationTransformer: DestinationTransformer) {
        self.sourceTransformer = sourceTransformer
        self.destinationTransformer = destinationTransformer
    }

    public func transform(destination value: Destination) -> Result<Source, TransformerError> {
        let interim = destinationTransformer.transform(destination: value)
        switch interim {
            case .success(let value):
                return sourceTransformer.transform(destination: value)
            case .failure(let error):
                return .failure(error)
        }
    }

    public func transform(source value: Source) -> Result<Destination, TransformerError> {
        let interim = sourceTransformer.transform(source: value)
        switch interim {
            case .success(let value):
                return destinationTransformer.transform(source: value)
            case .failure(let error):
                return .failure(error)
        }
    }
}
