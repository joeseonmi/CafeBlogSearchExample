//
//  Post.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

struct Post: Codable {
    let title: String            //블로그 글 제목
    let contents: String         //블로그 글 요약
    let url: String              //블로그 글 URL
    let blogName: String?        //블로그의 이름
    let cafeName: String?        //카페의 이름
    let thumbnailURL: String     //검색 시스템에서 추출한 대표 미리보기 이미지 URL
    let datetime: Date?           //[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss].000+[tz]
    
    enum CodingKeys: String, CodingKey {
        case title
        case contents
        case url
        case blogName = "blogname"
        case cafeName = "cafename"
        case thumbnailURL = "thumbnail"
        case datetime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.contents = try container.decode(String.self, forKey: .contents)
        self.url = try container.decode(String.self, forKey: .url)
        self.blogName = try? container.decode(String.self, forKey: .blogName)
        self.cafeName = try? container.decode(String.self, forKey: .cafeName)
        self.thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        if let date = try? container.decode(String.self, forKey: .datetime) {
            self.datetime = date.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
        } else {
            self.datetime = nil
        }
        
    }
}
