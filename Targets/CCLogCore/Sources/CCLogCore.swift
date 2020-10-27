
//
//  CCLog.swift
//  CCLogCore
//
//  Created by Alexander Weiss on 17/10/2020.
//  Copyright © 2020 Alexander Weiss. All rights reserved.
//

import Foundation
import ArgumentParser

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
"""#,
        subcommands: [TestCommand.self])

    public init() { }
}
