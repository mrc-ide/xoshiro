## xoshiro

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R build status](https://github.com/mrc-ide/xoshiro/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/xoshiro/actions)
[![CodeFactor](https://www.codefactor.io/repository/github/mrc-ide/xoshiro/badge)](https://www.codefactor.io/repository/github/mrc-ide/xoshiro)
[![codecov.io](https://codecov.io/github/mrc-ide/xoshiro/coverage.svg?branch=master)](https://codecov.io/github/mrc-ide/xoshiro?branch=master)
<!-- badges: end -->

Random numbers are hard, and getting them working in parallel is harder. There are lots of existing packages that help with this with the closest to our approach being [`dqrng`](https://cran.r-project.org/package=dqrng).

Our needs (and the reason for existance of this package) are that the the distribution functions (e.g., binomial random numbers) must be

* callable from C++
* callable from different threads (using, e.g., OpenMP)
* callable on a GPU
* able to run in `float` mode as well as `double`

In addition, for ease of testing we wanted a package that included no global state, and for flexibility (especially with co-existance of `Rcpp` and `cpp11`) we wanted a package that did not make assumptions about how the C++ code will interface with R (no boost depdnencies and no direct depdendency on either `Rcpp` or `cpp11`).

Our needs are also focussed on calls to distribution functions where subsequent calls to a function are unlikely to have the same parameters. For this reason we do not offer an interface to the C++ distribution functions.

## License

MIT © Imperial College of Science, Technology and Medicine
