context("utils")

test_that("null-or-value works", {
  expect_equal(1 %||% NULL, 1)
  expect_equal(1 %||% 2, 1)
  expect_equal(NULL %||% NULL, NULL)
  expect_equal(NULL %||% 2, 2)
})


test_that("assert_is", {
  thing <- structure(1, class = c("a", "b"))
  expect_silent(assert_is(thing, "a"))
  expect_silent(assert_is(thing, "b"))
  expect_silent(assert_is(thing, c("a", "b")))
  expect_error(assert_is(thing, "x"),
               "'thing' must be a x")
  expect_error(assert_is(thing, c("x", "y")),
               "'thing' must be a x / y")
})
