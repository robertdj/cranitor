#' Get test data
#'
#' Get test data in the *installed* `cranitor` package. Used in the tests of `cranitor`.
#'
#' @param filename The filename of the test file as it appears in `inst/testdata` *without* the
#' path.
#'
#' @return The full path of `filename`.
#'
#' @export
testdata_path <- function(filename) {
    system.file(
        file.path("testdata", filename), package = "cranitor",
        lib.loc = .libPaths()[1], mustWork = TRUE
    )
}
