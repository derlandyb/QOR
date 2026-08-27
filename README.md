<a id="readme-top"></a>

[![Issues][issues-shield]][issues-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![License: TBD][license-shield]][license-url]

<br />
<div align="center">
  <h3 align="center">QOR</h3>

  <p align="center">
    A music-event discovery platform for the Greater Vitória region — connecting fans with venues and promoters across mobile, web, and admin.
    <br />
    <a href="./.specs/project/PROJECT.md"><strong>Explore the specs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/derlandyb/qor-api">qor-api</a>
    &middot;
    <a href="https://github.com/derlandyb/qor-mobile">qor-mobile</a>
    &middot;
    <a href="https://github.com/derlandyb/qor-admin">qor-admin</a>
    &middot;
    <a href="https://github.com/derlandyb/qor-website">qor-website</a>
    &middot;
    <a href="https://github.com/derlandyb/qor-landingpage">qor-landingpage</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a>
      <ul><li><a href="#built-with">Built With</a></li></ul>
    </li>
    <li><a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [product-screenshot]: no screenshot yet — no application code exists in any repo yet, this is scaffolding only -->

**QOR** is a music-event discovery platform for Greater Vitória (Vitória, Vila Velha, Serra, Cariacica), connecting fans with venues and promoters across mobile, web, and admin surfaces. Fans browse events with no login required; Venues and Promoters self-register and publish events through a Super Admin approval gate; everything is region-scoped, LGPD-compliant, and localized entirely in Brazilian Portuguese.

This repo is the **project's spec/design workspace and submodule host** — it holds no application code of its own. It contains:

* `.specs/project/` — vision, requirements, architecture, and roadmap
* `.specs/features/` — per-feature specs and designs, with traceable requirement IDs
* `.specs/tasks/` — granular, per-platform implementation task breakdowns
* `design-system.md` (NIGHTLIFE-GV) — the design system shared by `qor-mobile`, `qor-website`, `qor-landingpage`
* `design-system-admin.md` — the separate, fully-adopted Corona-based design system used only by `qor-admin`

...and five submodules, each its own independently-versioned git repository:

| Repo | Stack | Responsibility |
|---|---|---|
| [`qor-api`](https://github.com/derlandyb/qor-api) | Laravel (PHP 8.4) | Auth, event discovery, approval workflow, favorites/social, notifications, billing |
| [`qor-mobile`](https://github.com/derlandyb/qor-mobile) | Kotlin Multiplatform + Compose + SwiftUI | Native Android/iOS fan app |
| [`qor-admin`](https://github.com/derlandyb/qor-admin) | Next.js | Super Admin / Venue / Promoter panel |
| [`qor-website`](https://github.com/derlandyb/qor-website) | Next.js | Public fan-facing website |
| [`qor-landingpage`](https://github.com/derlandyb/qor-landingpage) | Next.js | Public organizer-monetization landing page |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Laravel][Laravel.com]][Laravel-url]
* [![Next.js][Next.js]][Next-url]
* [![Kotlin][Kotlin.com]][Kotlin-url]
* [![Swift][Swift.com]][Swift-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

**No application code exists yet in any of the six repos** — this README documents the intended setup once scaffolding lands (see [Roadmap](#roadmap)), it does not describe a working stack today.

### Prerequisites

* Git (with submodule support)
* Docker + Docker Compose — orchestrates `qor-api`, `qor-admin`, `qor-website`, `qor-landingpage`, and the database; `qor-mobile` is the one repo not containerized
* Android Studio / Xcode, for `qor-mobile` specifically

### Installation

```sh
git clone --recurse-submodules https://github.com/derlandyb/QOR.git
cd QOR
make up
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

This repo is the source of truth for planning — every submodule is implemented task-by-task from [`.specs/tasks/`](./.specs/tasks). Start with [`PROJECT.md`](./.specs/project/PROJECT.md) for the product vision, [`ARCHITECTURE.md`](./.specs/project/ARCHITECTURE.md) for cross-cutting technical decisions, and [`ROADMAP.md`](./.specs/project/ROADMAP.md) for milestone status.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [ ] **MVP Core** — repo/CI scaffolding across all 5 submodules, event discovery, fan auth, Venue/Promoter registration + approval workflow
- [ ] **Social & Notifications** — favorites, friends graph, push/email notification dispatch
- [ ] **Monetization** — publishing plans, quota enforcement, landing page, Super Admin plan CRUD

Milestones are strictly sequential project-wide — see [`ROADMAP.md`](./.specs/project/ROADMAP.md) for full detail. See the [open issues](https://github.com/derlandyb/QOR/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions make the open source community an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion, please fork the repo and create a pull request. You can also simply open an issue. Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

No license has been chosen yet for this project. All rights reserved until a license is added.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Derlandy Belchior - derlandy.belchior@gmail.com

Project Link: [https://github.com/derlandyb/QOR](https://github.com/derlandyb/QOR)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[issues-shield]: https://img.shields.io/github/issues/derlandyb/QOR.svg?style=for-the-badge
[issues-url]: https://github.com/derlandyb/QOR/issues
[forks-shield]: https://img.shields.io/github/forks/derlandyb/QOR.svg?style=for-the-badge
[forks-url]: https://github.com/derlandyb/QOR/network/members
[stars-shield]: https://img.shields.io/github/stars/derlandyb/QOR.svg?style=for-the-badge
[stars-url]: https://github.com/derlandyb/QOR/stargazers
[license-shield]: https://img.shields.io/badge/license-TBD-lightgrey.svg?style=for-the-badge
[license-url]: #license
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org
[Kotlin.com]: https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white
[Kotlin-url]: https://kotlinlang.org
[Swift.com]: https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white
[Swift-url]: https://www.swift.org
