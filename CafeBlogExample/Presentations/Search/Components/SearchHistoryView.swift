//
//  SearchHistoryView.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/18.
//

import UIKit

import RxCocoa
import RxSwift

class SearchHistoryView: UIView {
    
    private lazy var stackView = UIStackView()
    fileprivate var selectHistory = PublishSubject<String>()
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func open() {
        self.disposeBag = DisposeBag()
        let histories = SearchHistoryManager.shared.getSearchHistory()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        histories.forEach { history in
            let button = UIButton()
            button.setAttributedTitle(title: history, font: .medium, size: 14)
            button.contentHorizontalAlignment = .leading
            button.rx.tap
                .map { history }
                .bind(to: selectHistory)
                .disposed(by: disposeBag)
            stackView.addArrangedSubview(button)
            button.snp.makeConstraints {
                $0.width.equalToSuperview()
            }
        }
    }
    
    private func attribute() {
        backgroundColor = .white
        stackView.spacing = 10
        stackView.axis = .vertical
    }
    
    private func layout() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
}

extension Reactive where Base: SearchHistoryView {
    var didTapHistory: PublishSubject<String> {
        return base.selectHistory
    }
}
