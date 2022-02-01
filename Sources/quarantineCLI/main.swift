import ArgumentParser
import Foundation

struct quarantineCLI: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(commandName: "quarantinecli", abstract: "A Command line tool to quarantine and de-quarantine files on macOS")
    /// The path to quarantine (if specified)
    @Option(
        name: [.customLong("quarantine"), .customShort("q")],
        help: ArgumentHelp("Quarantine a specified path", valueName: "path"),
        completion: .file())
    var quarantinePath: String?
    
    /// The path to de-quarantine (if specified)
    @Option(
        name: [.customLong("dequarantine"), .customShort("d")],
        help: ArgumentHelp("Dequarantine a specified path", valueName: "path"),
        completion: .file()
    )
    var dequarantinePath: String?
    
    /// The path to show quarantine status of (if specified)
    @Option(
        name: [.customLong("status"), .customShort("s")],
        help: ArgumentHelp("Show the quarantine staus of a specified path, and, if the path is quarantined, shows the quarantine properties of the path", valueName: "path"),
        completion: .file())
    var statusPath: String?
    
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
    
    @Option(
        help: "The actual URL of the quarantined item (optional)"
    )
    var itemURL: String?
    
    func run() throws {
        if let quarantinePath = quarantinePath {
            var url = URL(fileURLWithPath: quarantinePath)
            var resourceValues = URLResourceValues()
            var quarantineProperties: [String: Any] = [:]
            
            quarantineProperties[kLSQuarantineAgentNameKey as String] = agentName
            if let originURL = originURL {
                quarantineProperties[kLSQuarantineOriginURLKey as String] = originURL
            }
            
            if let bundleId = bundleId {
                quarantineProperties[kLSQuarantineAgentBundleIdentifierKey as String] = bundleId
            }
            
            if let itemURL = itemURL {
                quarantineProperties[kLSQuarantineDataURLKey as String] = itemURL
            }
            
            resourceValues.quarantineProperties = quarantineProperties
            try url.setResourceValues(resourceValues)
            print("Quarantined \(quarantinePath)")
        }
        
        if let dequarantinePath = dequarantinePath {
            var url = URL(fileURLWithPath: dequarantinePath)
            var resourceValues = URLResourceValues()
            resourceValues.quarantineProperties = nil
            try url.setResourceValues(resourceValues)
            print("De-quarantined \(dequarantinePath)")
        }
        
        if let statusPath = statusPath {
            let url = URL(fileURLWithPath: statusPath)
            let resourceValues = try url.resourceValues(forKeys: [.quarantinePropertiesKey])
            if let quarantineProperties = resourceValues.quarantineProperties {
                print("Path \(statusPath) is quarantined.")
                print("Quarantined Properties of file \(statusPath):")
                
                for (key, value) in quarantineProperties {
                    print("\(key): \(value)")
                }
            } else {
                print("Path \(statusPath) is not quarantined.")
            }
        }
        
    }
}

quarantineCLI.main()
