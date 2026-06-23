import SwiftUI
import Kingfisher

public struct ReviewsView: View {
    @ObservedObject private var presenter: ReviewsPresenter

    public init(presenter: ReviewsPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.stackMD) {
            HStack {
                Button(action: { presenter.didTapBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(uiColor: AppColor.onSurface))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glass)
                Spacer()
            }

            Text("Reviews")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(uiColor: AppColor.highEmphasis))

            ScrollView {
                LazyVStack(spacing: AppSpacing.stackMD) {
                    ForEach(presenter.viewModel.reviews) { review in
                        reviewCard(review)
                            .onAppear {
                                guard review.id == presenter.viewModel.reviews.last?.id else { return }
                                presenter.viewDidScrollNearBottom()
                            }
                    }

                    if presenter.viewModel.isLoadingMore {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.stackMD)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.containerMargin)
        .padding(.top, AppSpacing.containerMargin)
        .background(Color(uiColor: AppColor.background).ignoresSafeArea())
        .onAppear { presenter.viewDidAppear() }
        .alert("Error", isPresented: alertBinding) {
            Button("OK", role: .cancel) { presenter.alertMessage = nil }
        } message: {
            Text(presenter.alertMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { presenter.alertMessage != nil },
            set: { if !$0 { presenter.alertMessage = nil } }
        )
    }

    private func reviewCard(_ review: ReviewsViewModel.ReviewItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.base) {
            HStack(spacing: AppSpacing.stackMD) {
                if let url = review.avatarURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(uiColor: AppColor.surfaceContainerHigh))
                        .frame(width: 40, height: 40)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(uiColor: AppColor.highEmphasis))
                    Text(review.dateText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: AppColor.onSurfaceVariant))
                }
            }

            Text(review.content)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: AppColor.onSurface))
        }
        .padding(AppSpacing.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: AppColor.surfaceContainer))
        .cornerRadius(AppRadius.roundedLG)
    }
}
