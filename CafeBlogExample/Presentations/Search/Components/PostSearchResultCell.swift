//
//  PostSearchResultCell.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import UIKit
import Kingfisher

class PostSearchResultCell: UITableViewCell {
    
    private lazy var thumbnailView = UIImageView()
    private lazy var postTypeLabel = UILabel(font: .medium, size: 14, color: .red)
    private lazy var siteNameLabel = UILabel(font: .medium, size: 14, color: .darkGray)
    private lazy var titleLabel = UILabel(font: .semiBold, size: 16)
    private lazy var dateLabel = UILabel(font: .medium, size: 12, color: .darkGray)
    private lazy var divider = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDimState(id: Int) {
        let list = MoveToURLManager.shared.getMoveToURL()
        backgroundColor = list.contains(id) ? .lightGray : .white
    }
    
    func configureView(post: SearchResultCellData) {
        let thumbnailURL = URL(string: post.thumbnailURL)
        thumbnailView.kf.setImage(with: thumbnailURL)
        titleLabel.text = post.title
        
        postTypeLabel.text = post.type == .blog ? "BLOG" : "CAFE"
        siteNameLabel.text = post.type == .blog ? post.blogName : post.cafeName
      
        let calendar = Calendar(identifier: .gregorian)
        if let date = post.datetime {
            if calendar.isDateInToday(date) {
                dateLabel.text = "오늘"
            } else if calendar.isDateInYesterday(date) {
                dateLabel.text = "어제"
            } else if let dateText = date.toString(format: "yyyy년 MM월 dd일") {
                dateLabel.text = dateText
            }
        }
        
        if post.thumbnailURL.isEmpty {
            thumbnailView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.width.height.equalTo(0)
                $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
            titleLabel.snp.remakeConstraints {
                $0.top.equalTo(siteNameLabel.snp.bottom).offset(10)
                $0.leading.equalTo(postTypeLabel)
                $0.trailing.equalToSuperview().offset(-20)
            }
        } else {
            thumbnailView.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.width.equalToSuperview().multipliedBy(0.3)
                $0.height.equalTo(thumbnailView.snp.width)
                $0.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
            titleLabel.snp.remakeConstraints {
                $0.top.equalTo(siteNameLabel.snp.bottom).offset(10)
                $0.leading.equalTo(postTypeLabel)
                $0.trailing.equalTo(thumbnailView.snp.leading).offset(-10)
            }
        }
        self.updateDimState(id: post.hashValue)
    }
    
    private func attribute() {
        titleLabel.numberOfLines = 2
        postTypeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        siteNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        thumbnailView.layer.cornerRadius = 8
        thumbnailView.clipsToBounds = true
        divider.backgroundColor = .lightGray
        selectionStyle = .none
    }
    
    private func layout() {
        [
            thumbnailView,
            postTypeLabel,
            siteNameLabel,
            titleLabel,
            dateLabel,
            divider,
        ].forEach { contentView.addSubview($0) }
        
        thumbnailView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalToSuperview().multipliedBy(0.3)
            $0.height.equalTo(thumbnailView.snp.width)
            $0.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        postTypeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(siteNameLabel)
        }
        
        siteNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(postTypeLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualTo(thumbnailView.snp.leading).offset(-8)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(siteNameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(postTypeLabel)
            $0.trailing.equalTo(thumbnailView.snp.leading).offset(-10)
        }
        
        dateLabel.snp.makeConstraints {
            $0.bottom.equalTo(divider.snp.top).offset(-20)
            $0.leading.equalTo(postTypeLabel)
            $0.trailing.equalTo(thumbnailView.snp.leading).offset(-10)
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(8)
        }
        
        divider.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(1)
        }
        
    }
}
