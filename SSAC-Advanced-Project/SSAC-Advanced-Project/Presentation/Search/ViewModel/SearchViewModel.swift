//
//  SearchViewModel.swift
//  SSAC-Advanced-Project
//
//  Created by heerucan on 2022/10/24.
//

import Foundation

import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    
    var userList = PublishSubject<SearchUser>()
    
    struct Input {
        let searchText: ControlProperty<String?>
    }
    
    struct Output {
        let userList: PublishSubject<SearchUser>
        let searchText: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        let userList = userList
        let searchText = input.searchText
            .orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        return Output(userList: userList, searchText: searchText)
    }
    
    func requestSearchUser(query: String, page: Int) {
        GenericAPIManager.shared.requestData(SearchUser.self, PhotoRouter.searchUser(query, page)) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let value):
                self.userList.onNext(value)
                
            case .failure(let error):
                self.userList.onError(error)
                print(error.localizedDescription)
            }
        }
    }
}
