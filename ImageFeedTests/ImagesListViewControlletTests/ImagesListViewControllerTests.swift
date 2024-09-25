//
//  ImagesListViewControllerTests.swift
//  ImageFeedTests
//
//  Created by Maksim on 25.09.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) 
    }
    func testFetchInitialPhotosFailure() {
          // Given
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
          viewController.loadViewIfNeeded()
          let presenter = ImagesListPresenterSpy()
          viewController.configure(presenter)
          let mockImagesListService = ImagesListMockService()
          presenter.configureImagesListService(mockImagesListService)
          mockImagesListService.shouldReturnError = true
          
          
          // When
          presenter.fetchInitialPhotos()
          
          // Then
          XCTAssertFalse(presenter.reloadDataCalled)
      }
}
