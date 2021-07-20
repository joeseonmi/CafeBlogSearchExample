//
//  BlogResult.swift
//  CafeBlogExampleTests
//
//  Created by 조선미 on 2021/07/20.
//

import Foundation

@testable import CafeBlogExample

struct BlogResultDummy {
    let blogResultDummy = PostResponse(meta: Meta(totalCount: 3340210, pageableCount: 546, isEnd: false),
                                       documents: BlogDummyData().blogResultDummy)
}

extension BlogResultDummy {

    struct BlogDummyData {
        private let calendar = Calendar(identifier: .gregorian)
        let blogResultDummy: [Post] = [
            Post(title: "<b>고양이</b> 집사들이 한번쯤 꼭 찍고싶어 하는 사진", contents: "출처 : 여성시대 누가봐도 INFP 그것은 바로바로 <b>고양이</b> 하품샷! 잘 찍으면 이렇게 시원시원한 하품샷이 나오지만 타이밍이 조금이라도 어긋난다면.... 무서운 표정이...", url: "http://cafe.daum.net/subdued20club/ReHf/3359952", blogName: "＊여성시대＊ 차분한 20대들의 알흠다운 공간", cafeName: nil,thumbnailURL: "https://search2.kakaocdn.net/argon/130x130_85_c/EgtwqAJXsa6", datetime: Date()),
            Post(title: "🐱<b>고양이</b> 만쥬🐱", contents: "づ⌁⌁⌁❤︎⌁⌁⌁⋆ 몸과 마음의 양식...? 나 순간 책인줄 알고 응????? 했는데 열어보니 <b>고양이</b> 만쥬 였잔아!!!!!!!!!! 이거슴 바로바로!!! 워녕이 생일 기념 무나였던 !! 원영...", url: "http://cafe.daum.net/baemilytory/BzUs/195127", blogName: "밀리토리네", cafeName: nil, thumbnailURL: "https://search3.kakaocdn.net/argon/130x130_85_c/8PhkUhReBUe", datetime: Calendar.current.date(bySetting: .day, value: -1, of: Date()) ?? Date()),
            Post(title: "유기견&#39; 이어 ‘사지 절단된 새끼<b>고양이</b>’ 대구서 발견", contents: "057/0001581699?cds=news_edit &#39;두 눈 파인 유기견&#39; 이어 ‘사지 절단된 새끼<b>고양이</b>’ 대구서 발견 경기 안성에서 ‘두 눈이 파인 개’가 발견된 데 이어, 이번엔 대구...", url: "http://cafe.daum.net/SoulDresser/FLTB/413882", blogName: "소울드레서 (SoulDresser)", cafeName: nil, thumbnailURL: "", datetime: Calendar.current.date(bySetting: .day, value: -2, of: Date()) ?? Date()),
            Post(title: "나는 법을 가르쳐준 <b>고양이</b>》깜짝 출부 2탄 입니다😄✈", contents: "아드리한테 장문의 편지를 보내줬습니다. 《갈매기에게 나는 법을 가르쳐준 <b>고양이</b>》 제가 좋아하는 책이기도하고 지난 주 6학년 아이들 수업한 책 입니다. 아드리가...", url: "http://cafe.daum.net/SkyEagle/JtOD/631", blogName: "부모님과 곰신을 위한 공군가족",cafeName: nil, thumbnailURL: "https://search3.kakaocdn.net/argon/130x130_85_c/5pq3QNpR42V", datetime: Calendar.current.date(bySetting: .day, value: -3, of: Date()) ?? Date()),
        ]
    }
}
