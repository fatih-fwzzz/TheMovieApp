import SwiftUI
import Kingfisher
import UIComponentKit

public struct MovieDetailView: View {
    @ObservedObject var presenter: MovieDetailPresenter

    public init(presenter: MovieDetailPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    backdrop
                    identityRow
                    metadata
                    genreChips
                    overview
                    if presenter.viewModel.trailerURL != nil {
                        trailerButton
                    }
                    reviewsButton
                    castSection
                }
                .padding(.bottom, 32)
            }
            backButton
            favoriteButton
            if presenter.viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(uiColor: AppColor.background))
        .onAppear { presenter.viewDidAppear() }
    }

    private var backdrop: some View {
        Group {
            if let url = presenter.viewModel.backdropURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .clipped()
                    .overlay(
                        LinearGradient(colors: [.clear, Color(uiColor: AppColor.background)], startPoint: .top, endPoint: .bottom)
                    )
            }
        }
    }

    private var identityRow: some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = presenter.viewModel.posterURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .offset(y: -40)
            }
            Text(presenter.viewModel.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(uiColor: AppColor.highEmphasis))
                .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "star.fill").foregroundColor(Color(uiColor: AppColor.ratingGold))
                Text(presenter.viewModel.ratingText).foregroundColor(Color(uiColor: AppColor.ratingGold))
                Text("IMDB").font(.caption).padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color(uiColor: AppColor.surfaceContainerHigh))
                    .cornerRadius(4)
                Text(presenter.viewModel.year).foregroundColor(Color(uiColor: AppColor.onSurfaceVariant))
            }
            HStack {
                Image(systemName: "clock")
                Text(presenter.viewModel.runtimeText)
            }
            .font(.system(size: 12))
            .foregroundColor(Color(uiColor: AppColor.onSurfaceVariant))
        }
        .padding(.horizontal, 20)
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(presenter.viewModel.genres, id: \.self) { genre in
                    Text(genre)
                        .font(.system(size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(uiColor: AppColor.surfaceContainerHigh))
                        .foregroundColor(Color(uiColor: AppColor.onSurface))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(presenter.viewModel.overview)
                .font(.system(size: 16))
                .foregroundColor(Color(uiColor: AppColor.onSurfaceVariant))
                .lineLimit(presenter.viewModel.isOverviewExpanded ? nil : 3)
            if presenter.viewModel.overview.count > 120 {
                Button(presenter.viewModel.isOverviewExpanded ? "Show less" : "Read more") {
                    presenter.didToggleOverviewExpanded()
                }
                .foregroundColor(Color(uiColor: AppColor.primary))
            }
        }
        .padding(.horizontal, 20)
    }

    private var trailerButton: some View {
        Button(action: { presenter.didTapWatchTrailer() }) {
            Text("Watch Trailer")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(uiColor: AppColor.primaryContainer))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }

    private var reviewsButton: some View {
        Button(action: { presenter.didTapViewReviews() }) {
            HStack {
                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                Text("View Reviews")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(uiColor: AppColor.onSurface))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(uiColor: AppColor.surfaceContainer))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(uiColor: AppColor.outline), lineWidth: 1))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
    }

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Cast").font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text("See All").foregroundColor(Color(uiColor: AppColor.primary))
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(presenter.viewModel.cast, id: \.name) { member in
                        VStack(spacing: 6) {
                            if let url = member.imageURL {
                                KFImage(url).resizable().scaledToFill()
                                    .frame(width: 56, height: 56).clipShape(Circle())
                            } else {
                                Circle().fill(Color(uiColor: AppColor.surfaceContainerHigh)).frame(width: 56, height: 56)
                            }
                            Text(member.name).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                            Text(member.character).font(.system(size: 12)).foregroundColor(Color(uiColor: AppColor.onSurfaceVariant))
                        }
                        .frame(width: 80)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var backButton: some View {
        Button(action: { presenter.didTapBack() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color(uiColor: AppColor.onSurface))
                .padding(10)
                .background(Color(uiColor: AppColor.surfaceGlass))
                .clipShape(Circle())
        }
        .padding(.leading, 16)
        .padding(.top, 8)
    }

    private var favoriteButton: some View {
        HStack {
            Spacer()
            Button(action: { presenter.didTapFavorite() }) {
                Image(systemName: presenter.viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(presenter.viewModel.isFavorite ? Color(uiColor: AppColor.primary) : Color(uiColor: AppColor.onSurface))
                    .padding(10)
                    .background(Color(uiColor: AppColor.surfaceGlass))
                    .clipShape(Circle())
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
            .disabled(presenter.viewModel.isLoading)
        }
    }
}
