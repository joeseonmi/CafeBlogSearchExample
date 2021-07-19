//
//  PostDetailViewController.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import UIKit

import Kingfisher

import RxAppState
import RxCocoa
import RxSwift

protocol PostDetailViewBindable {
    var postData: Driver<SearchResultCellData> { get }
    var didTapMoveToWebView: PublishSubject<Void> { get }
    var pushWebViewURL: Driver<SearchResultCellData> { get }
    var viewWillDisappear: PublishSubject<Void> { get }
}

class PostDetailViewController: UIViewController {
    
    fileprivate lazy var scrollView = UIScrollView()
    fileprivate lazy var container = UIView()
    fileprivate lazy var thumbnailView = UIImageView()
    fileprivate lazy var siteNameLabel = UILabel(font: .medium, size: 14, color: .darkGray)
    fileprivate lazy var titleLabel = UILabel(font: .bold, size: 16, color: .black)
    fileprivate lazy var contentLabel = UILabel(font: .medium, size: 14, color: .black)
    fileprivate lazy var dateLabel = UILabel(font: .medium, size: 12, color: .darkGray)
    fileprivate lazy var urlLinkLabel = UILabel(font: .medium, size: 12, color: .darkGray)
    fileprivate lazy var moveToURLButton = UIButton()
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    func bind(viewModel: PostDetailViewBindable) {
        
        viewModel.postData
            .drive(self.rx.postData)
            .disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .map { _ in Void() }
            .bind(to: viewModel.viewWillDisappear)
            .disposed(by: disposeBag)
        
        moveToURLButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(to: viewModel.didTapMoveToWebView)
            .disposed(by: disposeBag)
        
        viewModel.pushWebViewURL
            .drive(self.rx.pushWebView)
            .disposed(by: disposeBag)
        
    }

    private func attribute() {
        view.backgroundColor = .white
        thumbnailView.layer.cornerRadius = 8
        thumbnailView.clipsToBounds = true
        titleLabel.numberOfLines = 2
        contentLabel.numberOfLines = 0
        moveToURLButton.backgroundColor = .red
        moveToURLButton.setAttributedTitle(title: "이동", font: .medium, size: 14, color: .white)
        moveToURLButton.layer.cornerRadius = 8
        navigationController?.isNavigationBarHidden = false
    }
    
    private func layout() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(container)
        
        [
            thumbnailView,
            siteNameLabel,
            titleLabel,
            contentLabel,
            dateLabel,
            urlLinkLabel,
            moveToURLButton,
        ].forEach { container.addSubview($0) }
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    
        container.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        thumbnailView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(20)
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(thumbnailView.snp.width)
        }
        
        siteNameLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(siteNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(siteNameLabel)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(siteNameLabel)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(siteNameLabel)
        }
        
        urlLinkLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(moveToURLButton.snp.leading).offset(-10)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        moveToURLButton.snp.makeConstraints {
            $0.centerY.equalTo(urlLinkLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalToSuperview().multipliedBy(0.2)
            $0.height.equalTo(30)
        }
        
    }

}


extension Reactive where Base: PostDetailViewController {
    var postData: Binder<SearchResultCellData> {
        return Binder(base) { base, post in
            let thumbnailURL = URL(string: post.thumbnailURL)
            base.thumbnailView.kf.setImage(with: thumbnailURL)
            base.titleLabel.text = post.title
            if let _ = post.blogName {
                base.title = "BLOG"
                base.siteNameLabel.text = post.blogName
            }
            if let _ = post.cafeName {
                base.title = "CAFE"
                base.siteNameLabel.text = post.cafeName
            }
            if let date = post.datetime,
               let dateText = date.toString(format: "yyyy년 MM월 dd일 a hh시 mm분") {
                base.dateLabel.text = dateText
            }
            base.contentLabel.text = post.contents
            base.urlLinkLabel.text = post.url
            
            if post.thumbnailURL.isEmpty {
                base.thumbnailView.snp.remakeConstraints {
                    $0.width.height.equalTo(0)
                }
            }
        }
    }
    
    var pushWebView: Binder<SearchResultCellData> {
        return Binder(base) { base, post in
            let vc = WebViewController()
            let viewModel = WebViewModel(post: post)
            vc.bind(viewModel: viewModel)
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
