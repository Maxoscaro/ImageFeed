//
//  WebViewViewContrillerSpy.swift
//  ImageFeed
//
//  Created by Maksim on 19.09.2024.
//

import Foundation

final class WebViewViewContrillerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    
    var loadRequestCalled = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
