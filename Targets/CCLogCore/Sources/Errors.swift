//
//  File.swift
//  
//
//  Created by Alexander Weiß on 28.10.20.
//

import Foundation
import Clibgit2

// MARK: - CCLogError
/// Errors specific to CCLog
public enum CCLogError: Error {
    case gitError(error: GitError)
    case tagQueryInvalid
    case failedToQueryTags
}

// MARK: - GitError
/// Possible errors when working with git
public enum GitError: Error {
    case failedToResolvePath(at: URL?)
    case unknown
}

extension GitError {
    init(from: NSError) {
        switch from.code {
        case -3:
            //TODO: Looks a little bit ugly
            let path = (from.userInfo["NSLocalizedDescription"] as? String)?.split(separator: "'")
            self = .failedToResolvePath(at: URL(string: String(path?[1] ?? "")))
        default:
            self = .unknown
        }
    }
}



