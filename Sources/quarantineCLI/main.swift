import ArgumentParser

struct QuarantineCLI: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "quarantinecli",
        abstract: "A CommandLine Tool to quarantine, de-quarantine, and manage quarantined files on macOS",
        subcommands: [quarantine.self, dequarantine.self, status.self]
    )
}

QuarantineCLI.main()
