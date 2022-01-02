import ArgumentParser
import Foundation

struct quarantine: ParsableCommand {
    
    static var configuration: CommandConfiguration = CommandConfiguration(abstract: "A Command line tool to quarantine and de-quarantine files on macOS")
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
    
    
    func run() throws {
        if let quarantinePath = quarantinePath {
            var url = URL(fileURLWithPath: quarantinePath)
            var resourceValues = URLResourceValues()
            resourceValues.quarantineProperties = [:]
            try url.setResourceValues(resourceValues)
            print("Quarantined file \(quarantinePath)")
        }
        
        if let dequarantinePath = dequarantinePath {
            var url = URL(fileURLWithPath: dequarantinePath)
            var resourceValues = URLResourceValues()
            resourceValues.quarantineProperties = nil
            try url.setResourceValues(resourceValues)
            print("De-quarantined file \(dequarantinePath)")
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

quarantine.main()
