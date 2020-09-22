#ifndef XOSHIRO_PRNG_HPP
#define XOSHIRO_PRNG_HPP

#include <algorithm>
#include "rng/xoshiro.hpp"
#include "distr/binomial.hpp"
#include "distr/normal.hpp"
#include "distr/poisson.hpp"
#include "distr/uniform.hpp"

namespace xoshiro {

template <typename T>
class prng { // # nocov
public:
  prng(const size_t n, const std::vector<uint64_t>& seed) {
    rng_state_t<T> s;
    auto len = rng_state_t<T>::size();
    auto n_seed = seed.size() / len;
    for (size_t i = 0; i < n; ++i) {
      if (i < n_seed) {
        std::copy_n(seed.begin() + i * len, len, s.state.begin());
      } else {
        xoshiro_jump(s);
      }
      _state.push_back(s);
    }
  }

  prng(const size_t n, const int seed)
    : prng(n, xoshiro::xoshiro_initial_seed<T>(seed)) {
  }

  size_t size() const {
    return _state.size();
  }

  void jump() {
    for (size_t i = 0; i < _state.size(); ++i) {
      xoshiro_jump(_state[i]);
    }
  }

  void long_jump() {
    for (size_t i = 0; i < _state.size(); ++i) {
      xoshiro_long_jump(_state[i]);
    }
  }

  rng_state_t<T>& state(size_t i) {
    return _state[i];
  }

  std::vector<uint64_t> export_state() {
    std::vector<uint64_t> state;
    const size_t n = rng_state_t<T>::size();
    state.reserve(size() * n);
    for (size_t i = 0; i < size(); ++i) {
      for (size_t j = 0; j < n; ++j) {
        state.push_back(_state[i][j]);
      }
    }
    return state;
  }

private:
  std::vector<rng_state_t<T>> _state;
};

}

#endif
