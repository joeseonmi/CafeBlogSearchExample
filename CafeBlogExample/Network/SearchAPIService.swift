//
//  SearchAPIService.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import Foundation

import Alamofire
import RxCocoa
import RxSwift

enum SearchError: Error {
    case defaultError
    case parseError
    
    var message: String {
        switch self {
        case .defaultError:
            return "네트워크 오류, 잠시 후 다시 시도 해 주세요"
        case .parseError:
            return "데이터 파싱에 실패 했습니다."
        }
    }
}

class SearchAPIService {

    static let shared = SearchAPIService()
    
    private init() { }
    
    private var baseURL = "https://dapi.kakao.com/v2/search/"
    
    private var header: HTTPHeaders {
        var header = HTTPHeaders()
        header.add(name: "Authorization",
                   value: "KakaoAK d5b71375acb0c1a05d59280d0b03759b")
        return header
    }
    
    func getCafePosts(query: String, page: Int) -> Observable<Result<PostResponse, SearchError>> {
        return Observable.create { observable -> Disposable in
            let parameters: [String: Any] = [
                "query": query,
                "page": page,
                "size": 25
            ]
            AF.request(self.baseURL + "cafe",
                       method: .get,
                       parameters: parameters,
                       headers: self.header)
                .responseJSON { response in
                    print("호잉", String(data: response.data!, encoding: .utf8))
                    switch response.result {
                    case .success:
                        guard let data = response.data else { return }
                        do {
                            let post = try JSONDecoder().decode(PostResponse.self, from: data)
                            observable.onNext(.success(post))
                            observable.onCompleted()
                        } catch {
                            observable.onNext(.failure(.parseError))
                            observable.onCompleted()
                        }
                    case .failure:
                        observable.onNext(.failure(.defaultError))
                        observable.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
    
    func getBlogPosts(query: String, page: Int) -> Observable<Result<PostResponse, SearchError>> {
        return Observable.create { observable -> Disposable in
            let parameters: [String: Any] = [
                "query": query,
                "page": page,
                "size": 25
            ]
            AF.request(self.baseURL + "blog",
                       method: .get,
                       parameters: parameters,
                       headers: self.header)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else { return }
                        do {
                            let post = try JSONDecoder().decode(PostResponse.self, from: data)
                            observable.onNext(.success(post))
                            observable.onCompleted()
                        } catch {
                            observable.onNext(.failure(.parseError))
                            observable.onCompleted()
                        }
                    case .failure:
                        observable.onNext(.failure(.defaultError))
                        observable.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
}
