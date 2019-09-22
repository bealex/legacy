//
// Result
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public extension Result {
    static func typeMismatchFatal(error: Error) -> Failure {
        fatalError("Error type mismatch. Expected \(Failure.self), but given \(type(of: error))")
    }

    init(_ value: Success?, _ error: @autoclosure () -> Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error())
        }
    }

    init(try closure: () throws -> Success, unknown: (Error) -> Failure = Result.typeMismatchFatal) {
        do {
            self = .success(try closure())
        } catch let error as Failure {
            self = .failure(error)
        } catch {
            self = .failure(unknown(error))
        }
    }

    func map<Result>(success: (Success) -> Result, failure: (Failure) -> Result) -> Result {
        switch self {
            case .success(let value):
                return success(value)
            case .failure(let error):
                return failure(error)
        }
    }

    // MARK: - Accessors

    var value: Success? { map(success: { $0 }, failure: { _ in nil }) }
    var error: Failure? { map(success: { _ in nil }, failure: { $0 }) }
}
