//
//  File.swift
//  
//
//  Created by Alexander Weiss on 14.03.21.
//

import Foundation


// MARK: - ChangeLog
extension ChangeLog: StencilContextConvertible {
    
    func convertToStencilContext() -> [String : Any] {
        return [
            "releases": self.releases?.compactMap { $0.convertToStencilContext() } ?? [:],
            "unreleased": self.unreleased?.convertToStencilContext() ?? [:]
        ]
    }
}

// MARK: - Release
extension Release: StencilContextConvertible {
    func convertToStencilContext() -> [String : Any] {
        return [
            "version": self.version.convertToStencilContext(),
            "changeSet": self.changeSet.convertToStencilContext(),
            "date": self.date
        ]
    }
}

// MARK: - Version
extension Version: StencilContextConvertible {
    func convertToStencilContext() -> [String : Any] {
        return [
            "value": self.value
        ]
    }
}

// MARK: - ChangeSet
extension ChangeSet: StencilContextConvertible {
    func convertToStencilContext() -> [String : Any] {
        return [
            "changes": self.changes.compactMap { $0.convertToStencilContext() }
        ]
    }
}

// MARK: - Change
extension Change: StencilContextConvertible {
    func convertToStencilContext() -> [String : Any] {
        return [
            "type": self.type ?? "",
            "scope": self.scope ?? "",
            "description": self.description ?? "",
            "body": self.description ?? "",
            "isBreaking": self.isBreaking,
            "contributor": self.contributor.convertToStencilContext()
        ]
    }
}

// MARK: - Change.Contributor
extension Change.Contributor: StencilContextConvertible {
    func convertToStencilContext() -> [String : Any] {
        return [
            "name": self.name,
            "email": self.email
        ]
    }
}

