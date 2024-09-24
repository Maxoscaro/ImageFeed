//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Maksim on 23.09.2024.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }


    func testViewControllerDidTapLogOut() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        //When
        presenter.logOutButtonTapped()
        
        //Then
        XCTAssertTrue(presenter.isLogoutButtonTapped)
    }
}
