#ifndef XOSHIRO_RNG_CPP11_HPP
#define XOSHIRO_RNG_CPP11_HPP

#include "rng.hpp"
#include <cpp11/raws.hpp>
#include <R_ext/Random.h>

namespace xoshiro {
namespace cpp11 {

template <typename T>
std::vector<uint64_t> as_rng_seed(::cpp11::sexp r_seed) {
  auto seed_type = TYPEOF(r_seed);
  std::vector<uint64_t> seed;
  if (seed_type == INTSXP || seed_type == REALSXP) {
    size_t seed_int = ::cpp11::as_cpp<size_t>(r_seed);
    seed = xoshiro::xoshiro_initial_seed<T>(seed_int);
  } else if (seed_type == RAWSXP) {
    ::cpp11::raws seed_data = ::cpp11::as_cpp<::cpp11::raws>(r_seed);
    const size_t len = sizeof(uint64_t) * xoshiro::rng_state_t<T>::size();
    if (seed_data.size() == 0 || seed_data.size() % len != 0) {
      using ::cpp11::stop;
      stop("Expected raw vector of length as multiple of %d for 'seed'",
           len);
    }
    seed.resize(seed_data.size() / sizeof(uint64_t));
    std::memcpy(seed.data(), RAW(seed_data), seed_data.size());
  } else if (seed_type == NILSXP) {
    GetRNGstate();
    size_t seed_int =
      std::ceil(std::abs(::unif_rand()) * std::numeric_limits<size_t>::max());
    PutRNGstate();
    seed = xoshiro::xoshiro_initial_seed<T>(seed_int);
  } else {
    ::cpp11::stop("Invalid type for 'seed'");
  }
  return seed;
}

}
}

#endif
