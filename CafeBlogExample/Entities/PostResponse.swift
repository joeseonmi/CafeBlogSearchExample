//
//  PostResponse.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

struct PostResponse: Codable {
    let meta: Meta
    let documents: [Post]
}
