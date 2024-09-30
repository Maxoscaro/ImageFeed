


import XCTest

class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        
        let authenticateButton = app.buttons["Authenticate"]
        let exists = authenticateButton.waitForExistence(timeout: 10)
        XCTAssertTrue(exists && authenticateButton.isHittable, "Кнопка 'Authenticate' не появилась вовремя или недоступна для нажатия")
    
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10))
        authenticateButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        let startPoint = webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText("")
        startPoint.referencedElement.swipeUp()
        
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        
        if passwordTextField.hasFocus {
            passwordTextField.typeText("")
        } else {
            passwordTextField.tap()
            passwordTextField.typeText("")
        }
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        sleep(5)
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like_button_off"].tap()
        cellToLike.buttons["like_button_on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    
    func testProfile() throws {
        sleep(6)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Max Anisimov"].exists)
        XCTAssertTrue(app.staticTexts["@maxoscaro"].exists)
        
        app.buttons["Exit"].tap()
        
        app.alerts["Пока, пока"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
        
    

