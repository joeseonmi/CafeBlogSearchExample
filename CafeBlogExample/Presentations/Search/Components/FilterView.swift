//
//  FilterView.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/17.
//

import UIKit

import RxCocoa
import RxSwift

class FilterView: UIView {
    
    private let stackView = UIStackView()
    private var filters: [FilterType] = []
    private var filterButtons: [FilterType: UIButton] = [:]
    
    fileprivate var tapFilter = PublishSubject<FilterType>()
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    private func bind() {
        tapFilter
            .withUnretained(self)
            .subscribe(onNext: { owner, filter in
                owner.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                owner.filters.removeAll()
                owner.filters = FilterType.allCases
                if let index = owner.filters.firstIndex(of: filter) {
                    owner.filters.remove(at: index)
                }
                owner.drawFilter()
            })
            .disposed(by: disposeBag)
    }
    
    private func setFilterButton() {
        FilterType.allCases.forEach { filter in
            let button = UIButton()
            button.setAttributedTitle(title: filter.title, font: .medium, size: 16, color: .black)
            button.setAttributedTitle(title: filter.title, font: .bold, size: 16, color: .red, for: .selected)
            button.rx.tap
                .map { filter }
                .bind(to: self.tapFilter)
                .disposed(by: disposeBag)
            self.filterButtons[filter] = button
        }
    }
    
    private func drawFilter() {
        filters.forEach { filter in
            if let button = self.filterButtons[filter] {
                self.stackView.addArrangedSubview(button)
                button.snp.makeConstraints {
                    $0.width.equalToSuperview()
                }
            }
        }
    }
    
    private func attribute() {
        backgroundColor = .white
        stackView.axis = .vertical
        stackView.spacing = 5

        filters = [.blog, .cafe]
        setFilterButton()
        drawFilter()
    }
    
    private func layout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }

}

extension Reactive where Base: FilterView {
    var didTapFilter: PublishSubject<FilterType> {
        return base.tapFilter
    }
}
