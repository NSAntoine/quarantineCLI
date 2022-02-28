import Foundation
import ArgumentParser

enum QuarantineErrors: Error, LocalizedError, CustomStringConvertible {
    case quarantinePathGivenUnreachable(path: String)
    case UnableToGetInfoSpecifiedFromQuarantineProperties(infoName: String)
    
    public var description: String {
        switch self {
        case .quarantinePathGivenUnreachable(let path):
            return "Path \"\(path)\" is unreachable"
        case .UnableToGetInfoSpecifiedFromQuarantineProperties(let infoName):
            return "Unable to get Value for key \(infoName) from Quarantine Dictionary"
        }
    }
    
    public var errorDescription: String? {
        return description
    }
}

/// The Subcommand for Quaranting a specified path
struct quarantine: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Quarantines a specified path"
    )
    
    @Argument(help: "The Path to quarantine")
    var path: String
    
    @Option(
        help: "The agent name to specify when quarantining a file"
    )
    var agentName: String = "quarantineCLI"
    
    @Option(
        help: "The Agent Bundle Identifier to set when quarantine a file (optional)"
    )
    var bundleId: String?
    
    @Option(
        help: "The URL of the resource originally hosting the quarantined file (optional)"
    )
    var originURL: String?
    
    func validate() throws {
        let url = URL(fileURLWithPath: path)
        // Make sure the URL is reachable
        guard try url.checkResourceIsReachable() else {
            throw QuarantineErrors.quarantinePathGivenUnreachable(path: path)
        }
    }
    
    func run() throws {
        var url = URL(fileURLWithPath: path)
        var resourceValues = URLResourceValues()
        var quarantineProperties: [String: Any] = [:]
        quarantineProperties[kLSQuarantineAgentNameKey as String] = agentName
        quarantineProperties[kLSQuarantineDataURLKey as String] = url
        
        if let bundleId = bundleId {
            quarantineProperties[kLSQuarantineAgentBundleIdentifierKey as String] = bundleId
        }
        
        if let originURL = originURL {
            quarantineProperties[kLSQuarantineOriginURLKey as String] = originURL
        }
        
        resourceValues.quarantineProperties = quarantineProperties
        try url.setResourceValues(resourceValues)
    }
}

/// The Subcommand for dequarantining a specified path
struct dequarantine: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Dequarantines a specified path"
    )
    
    @Argument(help: "The Path to dequarantine")
    var path: String
    
    func validate() throws {
        let url = URL(fileURLWithPath: path)
        guard try url.checkResourceIsReachable() else {
            throw QuarantineErrors.quarantinePathGivenUnreachable(path: path)
        }
    }
    
    mutating func run() throws {
        var url = URL(fileURLWithPath: path)
        var resourceValues = URLResourceValues()
        resourceValues.quarantineProperties = nil
        try url.setResourceValues(resourceValues)
    }
}

/// The Subcommand for getting the quarantine status of a path
struct status: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        abstract: "Prints whether or not the specified path is Quarnatined, and, if the path is quarantined, then print the Quarantine Properties of the path"
    )
    
    @Argument(help: "The Path to to examine the Quarantine Status of")
    var path: String
    
    @Argument(help: "The name of the Info key to parse from the Quarantine Properties (if the path given is quarantined) (optional)")
    var infoName: String?
    
    mutating func run() throws {
        let url = URL(fileURLWithPath: path)
        let resourceValues = try url.resourceValues(forKeys: [.quarantinePropertiesKey])
        if let quarantineProperties = resourceValues.quarantineProperties {
            print("Path \(path) is quarantined.")
            
            // if the user specified the info to parse from the Quarantine Properties
            // then parse it
            // otherwise, print all info from the quarantineProperties dictionary
            if let infoName = infoName {
                guard let info = quarantineProperties[infoName] else {
                    throw QuarantineErrors.UnableToGetInfoSpecifiedFromQuarantineProperties(infoName: infoName)
                }
                print("\(infoName): \(info)")
            } else {
                print("Quarantine Properties of path \(path):")
                for (key, value) in quarantineProperties {
                    print("\(key): \(value)")
                }
            }
        } else {
            print("Path \(path) is not quarantined.")
        }
    }
}
