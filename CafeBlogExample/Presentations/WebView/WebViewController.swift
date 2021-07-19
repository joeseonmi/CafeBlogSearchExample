//
//  WebViewController.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import UIKit

import WebKit

import RxCocoa
import RxSwift

protocol WebViewBindable {
    var postData: Driver<SearchResultCellData> { get }
}

class WebViewController: UIViewController, WKNavigationDelegate {

    fileprivate lazy var indicator = UIActivityIndicatorView()
    fileprivate lazy var webView = WKWebView()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    func bind(viewModel: WebViewBindable) {
        
        viewModel.postData
            .drive(self.rx.postData)
            .disposed(by: disposeBag)
        
    }
    
    private func attribute() {
        indicator.hidesWhenStopped = true
        indicator.color = .red
        webView.navigationDelegate = self
        indicator.startAnimating()
    }

    private func layout() {
        [
            webView,
            indicator,
        ].forEach { view.addSubview($0) }
        
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
}

extension Reactive where Base: WebViewController {
    var postData: Binder<SearchResultCellData> {
        return Binder(base) { base, post in
            base.title = post.title
            if let url = URL(string: post.url) {
                let request = URLRequest(url: url)
                base.webView.load(request)
            }
        }
    }
}
