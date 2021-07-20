//
//  SearchViewModel.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

import RxCocoa
import RxSwift

class SearchViewModel: SearchViewBindable {
    
    var didTapSearch = PublishSubject<String>()
    var didSelectSort = PublishSubject<SortType>()
    var didSelectFilter = PublishSubject<FilterType>()
    var didScroll = PublishSubject<Void>()
    var willDisplayCell = PublishSubject<Int>()
    var searchList: Driver<[SearchResultCellData]>
    var viewEndEditing: Signal<Void>
    var errorMessage: Signal<String>
    
    private var disposeBag = DisposeBag()
    private var searchedBlogPosts = BehaviorSubject<[Post]>(value: [])
    private var searchedCafePosts = BehaviorSubject<[Post]>(value: [])
    private var cellData = BehaviorSubject<[SearchResultCellData]>(value: [])
    private var cafeLastPage = PublishSubject<Bool>()
    private var blogLastPage = PublishSubject<Bool>()
    
    init(model: SearchModel = SearchModel()) {
        
        var cafePage = 1
        var blogPage = 1
        
        //CAFE DATA
        let searchCafeResult = didTapSearch
            .do(onNext: { [weak searchedCafePosts] _ in
                cafePage = 1
                searchedCafePosts?.onNext([])
            })
            .flatMapLatest{ model.getCafePosts(query: $0) }
            .share()
        
        let needMoreFetch = Observable
            .combineLatest(
                willDisplayCell,
                cellData
            )
            .map(model.needMoreFetch)
        
        let moreCafeResult = needMoreFetch
            .filter { $0 == true }
            .withLatestFrom(cafeLastPage)
            .filter { $0 == false }
            .do(onNext: { _ in
                cafePage += 1
            })
            .withLatestFrom(didTapSearch)
            .map { (keyword: $0, page: cafePage) }
            .flatMapLatest(model.getCafePosts)
            .share()
        
        let cafeSuccess = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
            .map { result -> PostResponse? in
                guard case .success(let value) = result else { return nil }
                return value
            }.compactMap { $0 }
        
        cafeSuccess
            .map { $0.meta.isEnd }
            .bind(to: cafeLastPage)
            .disposed(by: disposeBag)
       
        cafeSuccess
            .map { $0.documents }
            .bind(to: searchedCafePosts)
            .disposed(by: disposeBag)
        
        
        //1. 마지막셀일때
        //2. 페이징 -> 마지막 페이지일때 어떻게 처리할지
        //3. 키워드 + 페이지 해서 moreFetch 하고
        //4. 리턴
        
        //BLOG DATA
        let searchBlogResult = didTapSearch
            .do(onNext: { [weak searchedBlogPosts] _ in
                blogPage = 1
                searchedBlogPosts?.onNext([])
            })
            .flatMapLatest{ model.getBlogPosts(query: $0) }
            .share()
            
        let moreBlogResult = needMoreFetch
            .filter { $0 == true }
            .withLatestFrom(blogLastPage)
            .filter { $0 == false }
            .do(onNext: { _ in
                blogPage += 1
            })
            .withLatestFrom(didTapSearch)
            .map { (keyword: $0, page: cafePage) }
            .flatMapLatest(model.getBlogPosts)
            .share()
        
        let blogSuccess = Observable
            .merge(
                searchBlogResult,
                moreBlogResult
            )
            .map { result -> PostResponse? in
                guard case .success(let value) = result else { return nil }
                return value
            }.compactMap { $0 }
        
        blogSuccess
            .map { $0.meta.isEnd }
            .bind(to: blogLastPage)
            .disposed(by: disposeBag)
       
        blogSuccess
            .map { $0.documents }
            .bind(to: searchedBlogPosts)
            .disposed(by: disposeBag)
      
        
        //LAST PAGE
        let lastPage = Observable
            .combineLatest(cafeLastPage, blogLastPage)
        
        let lastPageMessage = needMoreFetch
            .filter { $0 == true }
            .withLatestFrom(lastPage)
            .filter { $0.0 == true && $0.1 == true }
            .map { _ -> String in
                return "마지막 페이지 입니다"
            }
        
        //View로 보낼 List 정리
        let result = Observable
            .merge(
                searchedBlogPosts,
                searchedCafePosts
            )
            .scan([], accumulator: model.merge)
            .map(model.parsData)
        
        result
            .withLatestFrom(didSelectFilter) { (list: $0, filter: $1) }
            .map(model.filteredData)
            .withLatestFrom(didSelectSort) { (list: $0, sort: $1) }
            .map(model.sortedData)
            .bind(to: cellData)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(didSelectFilter, didSelectSort)
            .map { $0.0 }
            .withLatestFrom(result) { (list: $1, filter: $0) }
            .map(model.filteredData)
            .withLatestFrom(didSelectSort) { (list: $0, sort: $1) }
            .map(model.sortedData)
            .bind(to: cellData)
            .disposed(by: disposeBag)
        
        searchList = cellData
            .asDriver(onErrorDriveWith: .empty())
        
        //View에서 EndEditing이 되어야 할 때
        viewEndEditing = Observable
            .merge(
                didScroll,
                didTapSearch.map { _ in Void() },
                didSelectFilter.map { _ in Void() },
                didSelectSort.map { _ in Void() }
            )
            .asSignal(onErrorSignalWith: .empty())
        
        //검색 결과 없을 때
        let empty = Observable
            .combineLatest(
                cafeSuccess.map { $0.documents },
                blogSuccess.map { $0.documents }
            )
            .map { cafe, blog -> String? in
                if (cafe + blog).count == 0 {
                    return "검색 결과가 없습니다."
                } else {
                    return nil
                }
            }.compactMap { $0 }
        
        let cafeFailure = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
        
        let blogFailure = Observable
            .merge(
                searchCafeResult,
                moreCafeResult
            )
        
        let errors = Observable
            .merge(
                cafeFailure,
                blogFailure
            )
            .map { result -> String? in
                guard case .failure(let error) = result else { return nil }
                return error.message
            }.compactMap { $0 }
        
        errorMessage = Observable
            .merge(
                errors,
                empty,
                lastPageMessage
            )
            .asSignal(onErrorSignalWith: .empty())
        
    }
    
    
}
