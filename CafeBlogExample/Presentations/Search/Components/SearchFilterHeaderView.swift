//
//  SearchFilterHeaderView.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import UIKit

import RxCocoa
import RxSwift

class SearchFilterHeaderView: UIView {
    
    fileprivate lazy var filterButton = UIButton()
    lazy var divider = UIView()
    fileprivate lazy var sortButton = UIButton()
    private lazy var bottomDivider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(sort: SortType) {
        sortButton.setAttributedTitle(title: sort.title, font: .medium, size: 16)
    }
    
    func set(filter: FilterType) {
        filterButton.setAttributedTitle(title: filter.title, font: .bold, size: 16, color: .red)
    }
    
    private func attribute() {
        filterButton.setAttributedTitle(title: FilterType.all.title, font: .bold, size: 16, color: .red)
        sortButton.setAttributedTitle(title: SortType.title.title, font: .medium, size: 16)
        bottomDivider.backgroundColor = .lightGray
        divider.backgroundColor = .lightGray
    }
    
    private func layout() {
        [
            filterButton,
            divider,
            sortButton,
            bottomDivider,
        ].forEach { addSubview($0) }
        
        filterButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(divider.snp.leading).offset(-20)
            $0.height.equalTo(40)
        }
        
        divider.snp.makeConstraints {
            $0.trailing.equalTo(sortButton.snp.leading).offset(-20)
            $0.centerY.equalTo(filterButton)
            $0.width.equalTo(1)
            $0.height.equalTo(20)
        }
        
        sortButton.snp.makeConstraints {
            $0.centerY.height.equalTo(filterButton)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-5)
            $0.width.equalToSuperview().multipliedBy(0.25)
        }
        
        bottomDivider.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        
    }
    
}

extension Reactive where Base: SearchFilterHeaderView {
    var didTapFilter: ControlEvent<Void> {
        let event = base.filterButton.rx.tap
        return event
    }
    
    var didTapSort: ControlEvent<Void> {
        let event = base.sortButton.rx.tap
        return event
    }
}
