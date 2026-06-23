import XCTest
import UIKit
import NetworkKit
@testable import HomeKit

final class HomePresenterTests: XCTestCase {
    private var sut: HomePresenter!
    private var mockView: MockHomeView!
    private var mockInteractor: MockHomeInteractor!
    private var mockRouter: MockHomeRouter!

    override func setUp() {
        super.setUp()
        mockView = MockHomeView()
        mockInteractor = MockHomeInteractor()
        mockRouter = MockHomeRouter()
        sut = HomePresenter(interactor: mockInteractor, router: mockRouter)
        sut.view = mockView
    }

    func test_viewDidLoad_fetchesInitialData() {
        let expectation = expectation(description: "initial load")
        mockView.onShow = { expectation.fulfill() }

        sut.viewDidLoad()
        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(mockInteractor.loadInitialCalled)
        XCTAssertNotNil(mockView.displayedViewModel)
    }

    func test_didSelectGenreChip_togglesGenre() {
        mockInteractor.genres = [Genre(id: 28, name: "Action")]
        let loadExpectation = expectation(description: "initial load")
        mockView.onShow = { loadExpectation.fulfill() }

        sut.viewDidLoad()
        wait(for: [loadExpectation], timeout: 2)

        let filterExpectation = expectation(description: "genre selected")
        mockView.onShow = { filterExpectation.fulfill() }
        sut.didSelectGenreChip(at: 0)
        wait(for: [filterExpectation], timeout: 2)
        XCTAssertEqual(mockInteractor.genreId, 28)

        let clearExpectation = expectation(description: "genre cleared")
        mockView.onShow = { clearExpectation.fulfill() }
        sut.didSelectGenreChip(at: 0)
        wait(for: [clearExpectation], timeout: 2)
        XCTAssertNil(mockInteractor.genreId)
    }
}

private final class MockHomeView: HomeView {
    var displayedViewModel: HomeViewModel?
    var onShow: (() -> Void)?

    func show(viewModel: HomeViewModel) {
        displayedViewModel = viewModel
        onShow?()
    }

    func show(errorMessage: String) {}
    func appendMovies(_ items: [HomeViewModel.MovieItem]) {}
    func showGridLoadingFooter(_ visible: Bool) {}
}

private final class MockHomeInteractor: HomeInteracting {
    var loadInitialCalled = false
    var genreId: Int?
    var genres: [Genre] = []

    func loadInitialData() async throws -> HomeInteractorResult {
        loadInitialCalled = true
        return HomeInteractorResult(
            trending: [Movie(id: 1, title: "Hero", overview: "Test", voteAverage: 8.0)],
            genres: genres,
            movies: PaginatedMoviesResponse(page: 1, totalPages: 1, results: [
                Movie(id: 2, title: "Grid", overview: "Test", voteAverage: 7.0)
            ]),
            selectedGenreId: genreId
        )
    }

    func loadMoreMovies() async throws -> [Movie] { [] }
    func trailerURL(for movieId: Int) async throws -> URL? { nil }

    func resetPagination(genreId: Int?) {
        self.genreId = genreId
    }
}

private final class MockHomeRouter: HomeRouting {
    var sourceViewController: UIViewController? { nil }
    func showMovieDetail(movieId: Int, from viewController: UIViewController) {}
    func openURL(_ url: URL, from viewController: UIViewController) {}
}
