//
//  SearchHistoryManager.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import Foundation

class SearchHistoryManager {
    
    static let shared = SearchHistoryManager()
    
    private let historyKey = "SearchHistory"
    
    private let userDefault = UserDefaults.standard
    
    private init() {  }
    
    func getSearchHistory() -> [String] {
        if let array = userDefault.array(forKey: historyKey) as? [String] {
            return array
        } else {
            return []
        }
    }
    
    func setHistory(keyword: String) {
        if keyword != "" {
            if var array =  userDefault.array(forKey: historyKey) as? [String] {
                if !array.contains(keyword) {
                    array.insert(keyword, at: 0)
                } else {
                    guard let index = array.firstIndex(of: keyword) else { return }
                    array.remove(at: index)
                    array.insert(keyword, at: 0)
                }
                userDefault.setValue(array, forKey: historyKey)
            } else {
                userDefault.setValue([keyword], forKey: historyKey)
            }
        }
    }
    
}
