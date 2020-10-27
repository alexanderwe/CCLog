//
//  TestCommand.swift
//  
//
//  Created by Alexander Weiß on 17.10.20.
//

import Foundation
import ArgumentParser
import SwiftGit2
import ConventionalCommits

struct TestCommand: ParsableCommand {

    public static let configuration = CommandConfiguration(abstract: "This is just a test command")


    func run() throws {
        
        
        let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
        print(c)
        
        
        
//        let url = URL(string: "./")!
//        let res = Repository.at(url)
//
//        switch res {
//        case let .success(repo):
//
//            let latestCommit = repo.commit(OID(string: "")!)
//
//
//            switch latestCommit {
//            case let .success(commit):
//
//                let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
//                print(c)
//
//            case let .failure(error):
//                print("Could not get commit: \(error)")
//            }
//
//        case let .failure(error):
//            print("Could not open repository: \(error)")
//        }
    }
}
