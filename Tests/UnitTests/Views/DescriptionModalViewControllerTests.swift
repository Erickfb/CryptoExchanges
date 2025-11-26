import XCTest
@testable import CryptoExchanges

final class DescriptionModalViewControllerTests: XCTestCase {
    var sut: DescriptionModalViewController!

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitializationWithDescription() {
        let description = "Test description"
        sut = DescriptionModalViewController(description: description)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.modalPresentationStyle, .overFullScreen)
        XCTAssertEqual(sut.modalTransitionStyle, .crossDissolve)
    }

    func testViewLoadsSuccessfully() {
        sut = DescriptionModalViewController(description: "Test")

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view)
        XCTAssertFalse(sut.view.subviews.isEmpty)
    }

    func testMarkdownProcessing() {
        let markdownText = "## Header\\n[Link](https://example.com)"
        sut = DescriptionModalViewController(description: markdownText)

        sut.loadViewIfNeeded()

        XCTAssertNotNil(sut.view)
    }

    func testCloseButton() {
        sut = DescriptionModalViewController(description: "Test")
        sut.loadViewIfNeeded()

        let closeButton = sut.view.subviews.compactMap { view -> UIButton? in
            findButton(in: view)
        }.first

        XCTAssertNotNil(closeButton)
    }

    private func findButton(in view: UIView) -> UIButton? {
        if let button = view as? UIButton {
            return button
        }
        for subview in view.subviews {
            if let button = findButton(in: subview) {
                return button
            }
        }
        return nil
    }
}
