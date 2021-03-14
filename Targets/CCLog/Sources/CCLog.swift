
//
//  CCLog.swift
//  CCLogCore
//
//  Created by Alexander Weiss on 17/10/2020.
//  Copyright © 2020 Alexander Weiss. All rights reserved.
//

import Foundation
import ArgumentParser
import CCLogCore

public struct CCLog: ParsableCommand {
    public static let configuration = CommandConfiguration(
        abstract: #"""

 ________      ________          ___           ________      ________
|\   ____\    |\   ____\        |\  \         |\   __  \    |\   ____\
\ \  \___|    \ \  \___|        \ \  \        \ \  \|\  \   \ \  \___|
 \ \  \        \ \  \            \ \  \        \ \  \\\  \   \ \  \  ___
  \ \  \____    \ \  \____        \ \  \____    \ \  \\\  \   \ \  \|\  \
   \ \_______\   \ \_______\       \ \_______\   \ \_______\   \ \_______\
    \|_______|    \|_______|        \|_______|    \|_______|    \|_______|
                                                                              
A Swift command-line tool to generate change log files for conventional commits
"""#
)
    
    // MARK: - Command line options
    @Argument(help: ArgumentHelp(
        "Path to your git repository",
        discussion: "If no path is provided the current directory is used."
    ))
    var gitPath: Path = Path(argument: "./")!
    
    @Argument(help: ArgumentHelp(
        "Path to your changelog template"
    ))
    var templatePath: Path
    
    @Option(name: [.customShort("f"), .long], help: "Regular expression of git tags to filter git tags")
    var tagFilter: String?
    
    @Option(name: [.customShort("q"), .long], help: "Query to specify range of git tags to include")
    var tagQuery: String

    // MARK: - Initializers
    public init() {
        
    }
    
    // MARK: - Validation
    public func validate() throws {
        guard gitPath.url != nil else {
            throw ValidationError("Provided git path is not valid")
        }
        
        guard templatePath.url != nil else {
            throw ValidationError("Provided template path is not valid")
        }
        
        guard !tagQuery.isEmpty else {
            throw ValidationError("Provided git query is not valid")
        }
    }
    
    // MARK: - Run
    public func run() throws {
        
        switch CCLogCore.generateGitLog(
            tagQuery: tagQuery,
            tagFilter: "[a-z]at",
            from: gitPath.url!,
            on: templatePath.url!
        ) {
        case .success:
            throw ExitCode.success
        case let .failure(error):
            print(error)
            throw ExitCode.failure
        }
    }
}
