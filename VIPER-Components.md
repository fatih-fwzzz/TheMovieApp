# TheMovie — VIPER Components Mapping

Architecture reference: [MoneyPortfolioApp/VIPER-Components.md](../MoneyPortfolioApp/VIPER-Components.md)

---

## VIPER Roles at a Glance

| Letter | Role | Responsibility |
|--------|------|----------------|
| **V** | View | Renders UI, forwards user actions to Presenter |
| **I** | Interactor | Fetches or provides business data |
| **P** | Presenter | Orchestrates flow, maps domain models → ViewModels |
| **E** | Entity | Plain domain data structures (`NetworkKit/Domain`) |
| **R** | Router | Handles navigation between screens |
| **Builder** | *(convention)* | Assembles and wires VIPER objects for a module |
| **Contracts** | *(convention)* | Protocols + ViewModel definitions per module |

---

## Module: Home (`HomeKit`)

| File | VIPER Role |
|------|------------|
| `HomeViewController.swift` | **View** |
| `HomeInteractor.swift` | **Interactor** |
| `HomePresenter.swift` | **Presenter** |
| `HomeRouter.swift` | **Router** |
| `HomeBuilder.swift` | **Builder** |
| `HomeContracts.swift` | **Contracts** |

Protocols: `HomeView`, `HomePresenting`, `HomeInteracting`, `HomeRouting`

---

## Module: Search (`SearchKit`)

| File | VIPER Role |
|------|------------|
| `SearchViewController.swift` | **View** |
| `SearchInteractor.swift` | **Interactor** |
| `SearchPresenter.swift` | **Presenter** |
| `SearchRouter.swift` | **Router** |
| `SearchBuilder.swift` | **Builder** |
| `SearchContracts.swift` | **Contracts** |

---

## Module: Favorites (`FavoritesKit`)

| File | VIPER Role |
|------|------------|
| `FavoritesViewController.swift` | **View** |
| `FavoritesInteractor.swift` | **Interactor** |
| `FavoritesPresenter.swift` | **Presenter** |
| `FavoritesRouter.swift` | **Router** |
| `FavoritesBuilder.swift` | **Builder** |
| `FavoritesContracts.swift` | **Contracts** |

---

## Module: Movie Detail (`DetailKit`)

| File | VIPER Role |
|------|------------|
| `MovieDetailView.swift` | **View** (SwiftUI) |
| `MovieDetailInteractor.swift` | **Interactor** |
| `MovieDetailPresenter.swift` | **Presenter** (`ObservableObject`) |
| `MovieDetailRouter.swift` | **Router** |
| `MovieDetailBuilder.swift` | **Builder** → `UIHostingController` |
| `MovieDetailContracts.swift` | **Contracts** |

---

## Module: Reviews (`ReviewKit`)

| File | VIPER Role |
|------|------------|
| `ReviewsViewController.swift` | **View** |
| `ReviewsInteractor.swift` | **Interactor** |
| `ReviewsPresenter.swift` | **Presenter** |
| `ReviewsBuilder.swift` | **Builder** |
| `ReviewsContracts.swift` | **Contracts** |

> Reviews is a leaf screen — no Router.

---

## Entity + Data (`NetworkKit`)

| File | Role |
|------|------|
| `MovieModels.swift` | **Entity** — `Movie`, `Genre`, `MovieDetail`, `Review`, etc. |
| `TMDBServiceProtocols.swift` | Service + pagination protocols |
| `TMDBMovieService.swift` | TMDB API implementation |
| `AlamofireNetworkService.swift` | HTTP client |
| `FavoritesStore.swift` | Local favorites persistence |

---

## App Composition Root

| File | Role |
|------|------|
| `AppRootBuilder.swift` | Builds `UITabBarController` with 3 tabs |
| `AppDependencies.swift` | Shared service container |
| `AppNavigation.swift` | Cross-pod routing adapter |
| `SceneDelegate.swift` | Window + `AppRootBuilder` |

---

## Navigation Flow

```
App Launch → Tab Bar (Home | Search | Favorites)
  → Movie Detail (SwiftUI)
    → User Reviews (UIKit)
```

Cross-pod navigation: feature Routers delegate to `AppNavigation`, which calls peer `Builder.build(...)`.
