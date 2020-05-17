#' Import Windows package
#'
#' Import Windos package `zip` file into a local CRAN by copying the file into the
#' appropriate folder.
#'
#' @inheritParams update_cran
#' @param package A vector with filenames (including path) of the `zip` files.
import_win_package <- function(cran_root, package) {
    assertthat::assert_that(tools::file_ext(package) == "zip")

    fs::file_copy(package, win_package_dir(cran_root))
}
