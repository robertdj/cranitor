#' Import Windows package
#'
#' Import Windos package `zip` file into a local CRAN by copying the file into the
#' appropriate folder.
#'
#' @inheritParams update_cran
#' @param package A vector with filenames (including path) of the `zip` files.
import_win_package <- function(cran_root, package, r_version) {
    assertthat::assert_that(
        assertthat::has_extension(package, "zip")
    )

    if (isFALSE(fs::dir_exists(win_package_dir(cran_root, r_version))))
        fs::dir_create(win_package_dir(cran_root, r_version))

    # TODO: copy or move?
    fs::file_copy(package, win_package_dir(cran_root, r_version))
}
