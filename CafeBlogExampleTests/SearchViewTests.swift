//
//  SearchViewTests.swift
//  CafeBlogExampleTests
//
//  Created by 조선미 on 2021/07/19.
//

import Foundation
import XCTest
import Quick
import Nimble

@testable import CafeBlogExample

class SearchViewTests: QuickSpec {
    
    override func spec() {
        
        let model = SearchModel()
        let cellList35 = CellDummy().cellResultDummy35
        let sortTestList = CellDummy().cellResultSortTest
        
        describe("검색결과 리스트에서") {
            context("마지막 셀에 도달 한 경우") {
                it("리스트의 갯수와 row가 같으면, 다음 페이지로 페이징 한다") {
                    expect(model.needMoreFetch(row: 20, cells: cellList35))
                        .to(beFalse(),
                            description: "list 갯수가 25가 넘지만 마지막 셀이 아니므로 페이징 하지 않는다.")
                    
                    expect(model.needMoreFetch(row: 34, cells: cellList35))
                        .to(beTrue(),
                            description: "list 갯수가 35이고 마지막 셀 이므로 페이징 한다")
                }
            }
        }
        
        describe("검색결과 리스트에서") {
            context("필터를 변경한 경우") {
                it("각 필터에 맞는 결과를 리턴한다") {
                    expect(model.filteredData(input: cellList35, filter: .blog).count)
                        .to(equal(4),
                            description: "리스트 중 블로그 포스트의 갯수가 4이므로 결과값 4를 반환한다")

                    expect(model.filteredData(input: cellList35, filter: .cafe).count)
                        .to(equal(31),
                            description: "리스트 중 카페 포스트의 갯수가 31이므로 결과값 31를 반환한다")
                    
                    expect(model.filteredData(input: cellList35, filter: .all).count)
                        .to(equal(35),
                            description: "모든 포스틍 갯수가 35이므로 결과값 35를 반환한다")
                }
            }
        }
        
        describe("검색결과 리스트에서") {
            context("정렬방식을 변경한 경우") {
                it("각 방식에 맞는 결과를 리턴한다") {
                    let datimeResult = sortTestList.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
                    let titleResult = sortTestList.sorted { $0.title < $1.title }
                    expect(model.sortedData(input: sortTestList, sort: .dateTime))
                        .to(equal(datimeResult),
                            description: "dateTime 기준으로 내림차순으로 정렬 되어야 한다 / 최신날짜 순")
                    
                    expect(model.sortedData(input: sortTestList, sort: .title))
                        .to(equal(titleResult),
                            description: "title 기준으로 오름차순으로 정렬 되어야 한다 / 제목 순")

                   
                }
            }
        }
        
        describe("검색 결과 페이징 이후") {
            context("blog, cafe 포스트 데이터가 있는 경우") {
                it("기존 리스트에 새로운 리스트를 추가한다.") {
                    let cafeData = CafeResultDummy().cafeResultDummy.documents
                    let blogData = BlogResultDummy().blogResultDummy.documents
                    
                    expect(model.merge(pre: cafeData, next: blogData).count)
                        .to(equal(35),
                            description: "next 리스트가 빈 리스트가 아닐 때 두 리스트를 합친 리스트가 반환된다")
                    
                    expect(model.merge(pre: cafeData, next: []).count)
                        .to(equal(0),
                            description: "새로운 리스트의 갯수가 0이면 빈 리스트를 반환한다 (리셋)")

                   
                }
            }
        }
        
    }
    

}
