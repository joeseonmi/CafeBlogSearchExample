//
//  MoveToURLManager.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/19.
//

import Foundation


class MoveToURLManager {
    
    static let shared = MoveToURLManager()
    
    private let moveToURLKey = "MoveToURL"
    
    private let userDefault = UserDefaults.standard
    
    func getMoveToURL() -> [Int] {
        if let urlArray = userDefault.array(forKey: moveToURLKey) as? [Int] {
            return urlArray
        } else {
            return []
        }
    }
    
    func setMoveToURL(id: Int) {
        if let array =  userDefault.array(forKey: moveToURLKey) as? [Int] {
            var setIDs = Set(array)
            setIDs.insert(id)
            userDefault.setValue(Array(setIDs), forKey: moveToURLKey)
        } else {
            userDefault.setValue([id], forKey: moveToURLKey)
        }
    }
}
