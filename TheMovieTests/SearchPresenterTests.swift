import XCTest
import UIKit
import NetworkKit
@testable import SearchKit

final class SearchPresenterTests: XCTestCase {
    private var sut: SearchPresenter!
    private var mockView: MockSearchView!
    private var mockInteractor: MockSearchInteractor!

    override func setUp() {
        super.setUp()
        mockView = MockSearchView()
        mockInteractor = MockSearchInteractor()
        sut = SearchPresenter(interactor: mockInteractor, router: MockSearchRouter())
        sut.view = mockView
    }

    func test_viewDidLoad_showsTrending() {
        let expectation = expectation(description: "trending loaded")
        mockView.onShow = { expectation.fulfill() }

        sut.viewDidLoad()
        wait(for: [expectation], timeout: 2)

        XCTAssertNotNil(mockView.viewModel)
        XCTAssertFalse(mockView.viewModel?.isSearching ?? true)
    }

    func test_searchQuery_showsSearchMode() {
        mockInteractor.searchResults = [Movie(id: 2, title: "Inception", releaseDate: "2010-01-01")]
        let expectation = expectation(description: "search completed")
        mockView.onShow = {
            guard let viewModel = self.mockView.viewModel,
                  viewModel.isSearching,
                  !viewModel.isLoading else { return }
            expectation.fulfill()
        }

        sut.searchQueryChanged("Inception")
        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(mockView.viewModel?.isSearching ?? false)
    }
}

private final class MockSearchView: SearchView {
    var viewModel: SearchViewModel?
    var onShow: (() -> Void)?

    func show(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        onShow?()
    }

    func show(errorMessage: String) {}
}

private final class MockSearchInteractor: SearchInteracting {
    var searchResults: [Movie] = []

    func fetchTrending() async throws -> [Movie] {
        [Movie(id: 1, title: "Trending", overview: "Tagline", voteAverage: 7.5)]
    }

    func searchMovies(query: String) async throws -> [Movie] { searchResults }
}

private final class MockSearchRouter: SearchRouting {
    func showMovieDetail(movieId: Int, from viewController: UIViewController) {}
}
