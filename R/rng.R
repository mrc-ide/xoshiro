##' @title Random Number Generator
##'
##' @description Create an object that can be used to generate random
##'   numbers in parallel.  This is primarily meant for debugging and
##'   testing; this package is meant to be used as a header-only
##'   package.
##'
##' @export
##' @examples
##' rng <- xoshiro::rng$new(42)
##'
##' # Shorthand for Uniform(0, 1)
##' rng$unif_rand(5)
##'
##' # Shorthand for Normal(0, 1)
##' rng$norm_rand(5)
##'
##' # Uniform random numbers between min and max
##' rng$runif(5, -2, 6)
##'
##' # Normally distributed random numbers with mean and sd
##' rng$rnorm(5, 4, 2)
##'
##' # Binomially distributed random numbers with size and prob
##' rng$rbinom(5, 10L, 0.3)
##'
##' # Poisson distributed random numbers with mean lambda
##' rng$rpois(5, 2)
rng <- R6::R6Class(
  "rng",
  cloneable = FALSE,

  private = list(
    ptr = NULL,
    n_generators = NULL
  ),

  public = list(
    ##' @description Create an `rng` object
    ##'
    ##' @param seed The seed, as an integer or as a raw vector.
    ##'
    ##' @param n_generators The number of generators to use. While this
    ##'   function never runs in parallel, this is used to create a set of
    ##'   interleaved independent generators.
    initialize = function(seed, n_generators = 1L) {
      private$ptr <- xoshiro_rng_alloc(seed, n_generators)
    },

    ##' @description Number of generators available
    size = function() {
      xoshiro_rng_size(private$ptr)
    },

    ##' @description The jump function for the generator, equivalent to
    ##' 2^128 numbers drawn from the generator.
    jump = function() {
      xoshiro_rng_jump(private$ptr)
      invisible(self)
    },

    ##' @description The `long_jump` function for the generator, equivalent
    ##' to 2^192 numbers drawn from the generator.
    long_jump = function() {
      xoshiro_rng_long_jump(private$ptr)
      invisible(self)
    },

    ##' Generate `n` numbers from a standard uniform distribution
    ##'
    ##' @param n Number of samples to draw
    unif_rand = function(n) {
      xoshiro_rng_unif_rand(private$ptr, n)
    },

    ##' Generate `n` numbers from a standard normal distribution
    ##'
    ##' @param n Number of samples to draw
    norm_rand = function(n) {
      xoshiro_rng_norm_rand(private$ptr, n)
    },

    ##' Generate `n` numbers from a uniform distribution
    ##'
    ##' @param n Number of samples to draw
    ##'
    ##' @param min The minimum of the distribution (length 1 or n)
    ##'
    ##' @param max The maximum of the distribution (length 1 or n)
    runif = function(n, min, max) {
      xoshiro_rng_runif(private$ptr, n, recycle(min, n), recycle(max, n))
    },

    ##' Generate `n` numbers from a normal distribution
    ##'
    ##' @param n Number of samples to draw
    ##'
    ##' @param mean The mean of the distribution (length 1 or n)
    ##'
    ##' @param sd The standard deviation of the distribution (length 1 or n)
    rnorm = function(n, mean, sd) {
      xoshiro_rng_rnorm(private$ptr, n, recycle(mean, n), recycle(sd, n))
    },

    ##' Generate `n` numbers from a binomial distribution
    ##'
    ##' @param n Number of samples to draw
    ##'
    ##' @param size The number of trials (zero or more, length 1 or n)
    ##'
    ##' @param prob The probability of success on each trial
    ##'   (between 0 and 1, length 1 or n)
    rbinom = function(n, size, prob) {
      xoshiro_rng_rbinom(private$ptr, n, recycle(size, n), recycle(prob, n))
    },

    ##' Generate `n` numbers from a Poisson distribution
    ##'
    ##' @param n Number of samples to draw
    ##'
    ##' @param lambda The mean (zero or more, length 1 or n)
    rpois = function(n, lambda) {
      xoshiro_rng_rpois(private$ptr, n, recycle(lambda, n))
    },

    ##' @description
    ##' Returns the state of the random number generator. This returns a
    ##' raw vector of length 32 * n_generators. It is primarily intended for
    ##' debugging as one cannot (yet) initialise an `rng` object with this
    ##' state.
    state = function() {
      xoshiro_rng_state(private$ptr)
    }
  ))


##' Advance a saved random number state by performing a "long jump" on
##' it. Intended for if you have serialised an RNG state (using the
##' `$state()` method, or via some application using `xoshiro`) but want
##' create a new seed that is uncorrelated.  If the state extracted is
##' to be reused multiple times, then the state needs jumping to
##' prevent generating the same sequence of random numbers.
##'
##' @title Advance random number state
##'
##' @param state A raw vector representing `xoshiro` random number
##'   generator; see [`xoshiro::rng`].
##'
##' @param times An integer indicating the number of times the
##'   `long_jump` should be performed. The default is one, but values
##'   larger than one will repeatedly advance the state.
##'
##' @export
##' @examples
##' # Create a new RNG object
##' rng <- xoshiro::rng$new(1)
##'
##' # Serialise the state as a raw vector
##' state <- rng$state()
##'
##' # We can advance this state
##' xoshiro::rng_state_long_jump(state)
##'
##' # Which gives the same result as long_jump on the original generator
##' rng$long_jump()$state()
##' rng$long_jump()$state()
##'
##' # Multiple jumps can be taken by using the "times" argument
##' xoshiro::rng_state_long_jump(state, 2)
rng_state_long_jump <- function(state, times = 1L) {
  assert_is(state, "raw")
  r <- rng$new(state)
  for (i in seq_len(times)) {
    r$long_jump()
  }
  r$state()
}


recycle <- function(x, n, name = deparse(substitute(x))) {
  if (length(x) == n) {
    x
  } else if (length(x) == 1L) {
    rep_len(x, n)
  } else {
    stop(sprintf("Invalid length for '%s', expected 1 or %d", name, n))
  }
}
