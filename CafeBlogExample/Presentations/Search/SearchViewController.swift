//
//  SearchViewController.swift
//  CafeBlogExample
//
//  Created by 조선미 on 2021/07/16.
//

import UIKit

import RxCocoa
import RxSwift

protocol SearchViewBindable {
    var didTapSearch: PublishSubject<String> { get }
    var didSelectSort: PublishSubject<SortType> { get }
    var didSelectFilter: PublishSubject<FilterType> { get }
    var didScroll: PublishSubject<Void> { get }
    var willDisplayCell: PublishSubject<Int> { get }
    
    var searchList: Driver<[SearchResultCellData]> { get }
    var viewEndEditing: Signal<Void> { get }
    var errorMessage: Signal<String> { get }
}

class SearchViewController: UIViewController {
    
    private lazy var searchBar = UISearchBar()
    private lazy var searchButton = UIButton()
    private lazy var divider = UIView()
    private lazy var tableView = UITableView()
    fileprivate lazy var filterHeaderView = SearchFilterHeaderView()
    fileprivate lazy var filterView = FilterView()
    fileprivate lazy var historyView = SearchHistoryView()
    fileprivate lazy var blackBGView = UIView()
    
    private var disposeBag = DisposeBag()
    private var viewModel: SearchViewBindable!
    
    fileprivate var didSelectSort = BehaviorSubject<SortType>(value: .title)
    fileprivate var didSelectFilter = BehaviorSubject<FilterType>(value: .all)
    private var tapView = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
    }
    
    func bind(viewModel: SearchViewBindable) {
        
       let didTapSearch = searchButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { owner in owner.0.searchBar.text ?? "" }
            
        let didTapHistory = historyView.rx.didTapHistory
            .withUnretained(self)
            .do(onNext: { owner, keyword in
                owner.searchBar.text = keyword
            })
            .map { $1 }
        
        Observable
            .merge(didTapSearch, didTapHistory)
            .filter { $0 != "" }
            .do(onNext: { SearchHistoryManager.shared.setHistory(keyword: $0) })
            .bind(to: viewModel.didTapSearch)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.navigationController?.isNavigationBarHidden = true
            }).disposed(by: disposeBag)
        
        viewModel.searchList.drive(tableView.rx.items) { tableView, row, item in
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostSearchResultCell.self),
                                                        for: indexPath) as? PostSearchResultCell {
                cell.configureView(post: item)
                return cell
            } else {
                return UITableViewCell()
            }
        }
        .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(SearchResultCellData.self)
            .withUnretained(self)
            .subscribe(onNext: { owner, post in
                let vc = PostDetailViewController()
                let viewModel = PostDetailViewModel(post: post)
                vc.bind(viewModel: viewModel)
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        let seletedCell = Observable
            .combineLatest(tableView.rx.itemSelected,
                           tableView.rx.modelSelected(SearchResultCellData.self))

        self.rx.viewWillAppear
            .withLatestFrom(seletedCell)
            .subscribe(onNext: { index, post in
                if let cell = self.tableView.cellForRow(at: index) as? PostSearchResultCell {
                    cell.updateDimState(id: post.hashValue)
                }
            }).disposed(by: self.disposeBag)
            
        
        tableView.rx.didScroll
            .bind(to: viewModel.didScroll)
            .disposed(by: self.disposeBag)
        
        tableView.rx.willDisplayCell
            .map { $0.indexPath.row }
            .bind(to: viewModel.willDisplayCell)
            .disposed(by: self.disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .bind(to: self.rx.showHistories)
            .disposed(by: self.disposeBag)
        
        filterHeaderView.rx.didTapFilter
            .bind(to: self.rx.showFilter)
            .disposed(by: self.disposeBag)
        
        filterHeaderView.rx.didTapSort
            .bind(to: self.rx.showSort)
            .disposed(by: self.disposeBag)
        
        didSelectSort
            .bind(to: viewModel.didSelectSort)
            .disposed(by: self.disposeBag)
        
        didSelectSort
            .withUnretained(self)
            .subscribe(onNext: { owner, sort in
                owner.filterHeaderView.set(sort: sort)
            })
            .disposed(by: self.disposeBag)
        
        filterView.rx.didTapFilter
            .bind(to: didSelectFilter)
            .disposed(by: self.disposeBag)
        
        didSelectFilter
            .bind(to: viewModel.didSelectFilter)
            .disposed(by: self.disposeBag)
        
        didSelectFilter
            .withUnretained(self)
            .subscribe(onNext: { owner, filter in
                owner.filterHeaderView.set(filter: filter)
            })
            .disposed(by: self.disposeBag)
        
        Observable
            .merge(viewModel.viewEndEditing.asObservable(),
                   tapView)
            .do(onNext: { self.view.endEditing(true) })
            .bind(to: self.rx.hideFilter, self.rx.hideHistories, self.rx.hideHistories)
            .disposed(by: self.disposeBag)
        
        viewModel.errorMessage
            .emit(to: self.rx.showMessage)
            .disposed(by: self.disposeBag)
    }
    
    private func attribute() {
        view.backgroundColor = .white
        searchButton.setAttributedTitle(title: "검색", font: .medium, size: 16)
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "검색어를 입력 해 주세요"
        tableView.separatorStyle = .none
        divider.backgroundColor = .lightGray
        tableView.register(PostSearchResultCell.self,
                           forCellReuseIdentifier: String(describing: PostSearchResultCell.self))
        tableView.tableHeaderView = filterHeaderView
        filterView.isHidden = true
        historyView.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapView(sender:)))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        blackBGView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        blackBGView.isHidden = true
    }
    
    @objc
    private func tapView(sender: UITapGestureRecognizer) {
        self.tapView.onNext(())
    }

    private func layout() {
        [
            searchBar,
            searchButton,
            divider,
            tableView,
            blackBGView,
            filterView,
            historyView,
        ].forEach { view.addSubview($0) }
        
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeArea.top)
            $0.leading.equalToSuperview().offset(10)
            $0.height.equalTo(searchButton)
        }
        
        searchButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.equalTo(searchBar.snp.trailing)
            $0.centerY.equalTo(searchBar)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        filterHeaderView.snp.makeConstraints {
            $0.width.top.leading.trailing.bottom.equalToSuperview()
        }
        
        blackBGView.snp.makeConstraints {
            $0.top.equalTo(filterHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        filterView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(self.filterHeaderView.divider.snp.leading)
            $0.top.equalTo(self.filterHeaderView.snp.bottom)
        }
        
        historyView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(searchBar.snp.trailing)
        }
    }
}

extension Reactive where Base: SearchViewController {
    
    var showMessage: Binder<String> {
        return Binder(base) { base, msg in
            let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
            alertController.addAction(confirm)
            base.present(alertController, animated: true, completion: nil)
        }
    }
    
    var showSort: Binder<Void> {
        return Binder(base) { base, _  in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let sort = SortType.allCases
            sort.forEach { sort in
                let action = UIAlertAction(title: sort.title, style: .default) { [weak base] _ in
                    base?.didSelectSort.onNext(sort)
                }
                alertController.addAction(action)
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(cancel)
            base.present(alertController, animated: true, completion: nil)
        }
    }
    
    var showFilter: Binder<Void> {
        return Binder(base) { base, _  in
            base.filterView.isHidden = !base.filterView.isHidden
            base.blackBGView.isHidden = base.filterView.isHidden
            if !base.blackBGView.isHidden {
                base.blackBGView.snp.remakeConstraints {
                    $0.top.equalTo(base.filterHeaderView.snp.bottom)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            }
        }
    }
    
    var hideFilter: Binder<Void> {
        return Binder(base) { base, _  in
            base.filterView.isHidden = true
            base.blackBGView.isHidden = base.filterView.isHidden
        }
    }
    
    var showHistories: Binder<Void> {
        return Binder(base) { base, _  in
            if SearchHistoryManager.shared.getSearchHistory().count != 0 {
                base.historyView.isHidden = !base.historyView.isHidden
                if !base.historyView.isHidden {
                    base.historyView.open()
                }
            } else {
                base.historyView.isHidden = true
            }
            base.blackBGView.isHidden = base.historyView.isHidden
            if !base.blackBGView.isHidden {
                base.blackBGView.snp.remakeConstraints {
                    $0.top.equalTo(base.filterHeaderView.snp.top)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            }
        }
    }
    
    var hideHistories: Binder<Void> {
        return Binder(base) { base, _  in
            base.historyView.isHidden = true
            base.blackBGView.isHidden = base.historyView.isHidden
        }
    }
}
