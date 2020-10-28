//
//  CCLogCore.swift
//  
//
//  Created by Alexander Weiß on 28.10.20.
//

import Foundation
import ConventionalCommits
import SwiftGit2





public enum CCLogCore {
    public static func generateGitLog(from repository: URL) -> Result<Void, CCLogError> {
        let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
        print(c)
        
        
        
        let res = Repository.at(repository)
        switch res {
        case let .success(repo):
            break;
        case let .failure(error):
            return .failure(.gitError(error: GitError(from: error)))
        }
        
        
        
        
        return .success(())
        
        
        
        
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
