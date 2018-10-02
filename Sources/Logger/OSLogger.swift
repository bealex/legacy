//
// OSLogger
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import os.log

/// Simple os_log logger. Output is similar to NSLogLogger, but does not have its limitations. Output goes to stdout.
public class OSLogger: Logger {
    private let applicationPrefix: String

    public init(applicationPrefix: String) {
        self.applicationPrefix = applicationPrefix
    }

    private func name(for level: LoggingLevel) -> String {
        switch level {
            case .verbose:
                return "💬️"
            case .debug:
                return "🔬"
            case .info:
                return "🌵"
            case .warning:
                return "🖖"
            case .error:
                return "⛑"
        }
    }

    private func logType(for level: LoggingLevel) -> OSLogType {
        switch level {
            case .verbose:
                return .debug
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .error
            case .error:
                return .fault
        }
    }

    public func log(_ message: @autoclosure () -> String, level: LoggingLevel, tag: String, function: String) {
        os_log(logType(for: level), log: osLog(for: tag), "%@ %@", name(for: level), message())
    }

    private var osLogs: [String: OSLog] = [:]

    private func osLog(for tag: String) -> OSLog {
        let log = osLogs[tag]
        if let log = log {
            return log
        } else {
            let log = OSLog(subsystem: applicationPrefix, category: tag)
            osLogs[tag] = log
            return log
        }
    }
}
