# TheMovie — VIPER Components Mapping

Architecture reference: [MoneyPortfolioApp/VIPER-Components.md](../MoneyPortfolioApp/VIPER-Components.md)

---

## Project Structure

All source lives in the **TheMovie** app target (no local CocoaPods modules):

```
TheMovie/
  App/                    — App shell, DI, navigation
  Core/
    Network/              — TMDB client, models, favorites store
    UI/                   — Design system + shared components
  Features/
    Home/
    Search/
    Favorites/
    Detail/
    Reviews/
```

Third-party libraries (Kingfisher, Alamofire, SkeletonView, Hero) remain in the Podfile.

---

## VIPER Roles at a Glance

| Letter | Role | Responsibility |
|--------|------|----------------|
| **V** | View | Renders UI, forwards user actions to Presenter |
| **I** | Interactor | Fetches or provides business data |
| **P** | Presenter | Orchestrates flow, maps domain models → ViewModels |
| **E** | Entity | Plain domain data structures (`Core/Network`) |
| **R** | Router | Handles navigation between screens |
| **Builder** | *(convention)* | Assembles and wires VIPER objects for a module |
| **Contracts** | *(convention)* | Protocols + ViewModel definitions per module |

---

## Feature: Home (`TheMovie/Features/Home`)

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

## Feature: Search (`TheMovie/Features/Search`)

| File | VIPER Role |
|------|------------|
| `SearchViewController.swift` | **View** |
| `SearchInteractor.swift` | **Interactor** |
| `SearchPresenter.swift` | **Presenter** |
| `SearchRouter.swift` | **Router** |
| `SearchBuilder.swift` | **Builder** |
| `SearchContracts.swift` | **Contracts** |

---

## Feature: Favorites (`TheMovie/Features/Favorites`)

| File | VIPER Role |
|------|------------|
| `FavoritesViewController.swift` | **View** |
| `FavoritesInteractor.swift` | **Interactor** |
| `FavoritesPresenter.swift` | **Presenter** |
| `FavoritesRouter.swift` | **Router** |
| `FavoritesBuilder.swift` | **Builder** |
| `FavoritesContracts.swift` | **Contracts** |

---

## Feature: Movie Detail (`TheMovie/Features/Detail`)

| File | VIPER Role |
|------|------------|
| `MovieDetailViewController.swift` | **View** (UIKit) |
| `MovieDetailInteractor.swift` | **Interactor** |
| `MovieDetailPresenter.swift` | **Presenter** |
| `MovieDetailRouter.swift` | **Router** |
| `MovieDetailBuilder.swift` | **Builder** |
| `MovieDetailContracts.swift` | **Contracts** |

---

## Feature: Reviews (`TheMovie/Features/Reviews`)

| File | VIPER Role |
|------|------------|
| `ReviewsView.swift` | **View** (SwiftUI) |
| `ReviewsInteractor.swift` | **Interactor** |
| `ReviewsPresenter.swift` | **Presenter** |
| `ReviewsBuilder.swift` | **Builder** |
| `ReviewsContracts.swift` | **Contracts** |

> Reviews is a leaf screen — no Router.

---

## Entity + Data (`TheMovie/Core/Network`)

| File | Role |
|------|------|
| `MovieModels.swift` | **Entity** — `Movie`, `Genre`, `MovieDetail`, `Review`, etc. |
| `TMDBServiceProtocols.swift` | Service + pagination protocols |
| `TMDBMovieService.swift` | TMDB API implementation |
| `AlamofireNetworkService.swift` | HTTP client |
| `FavoritesStore.swift` | Local favorites persistence |

---

## App Composition Root (`TheMovie/App`)

| File | Role |
|------|------|
| `AppRootBuilder.swift` | Builds `UITabBarController` with 3 tabs |
| `AppDependencies.swift` | Shared service container |
| `AppNavigation.swift` | Cross-feature routing adapter |
| `SceneDelegate.swift` | Window + `AppRootBuilder` |

---

## Navigation Flow

```
App Launch → Tab Bar (Home | Search | Favorites)
  → Movie Detail (UIKit)
    → User Reviews (SwiftUI)
```

Cross-feature navigation: feature Routers delegate to `AppNavigation`, which calls peer `Builder.build(...)`.
