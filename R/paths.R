#' The path of the source package folder
#'
#' @inheritParams update_cran
source_package_dir <- function(cran_root) {
    fs::path(cran_root, "src", "contrib")
}


#' The path of the Windows package folder
#'
#' @inheritParams update_cran
#' @param r_version An `R_system_version` -- the result of e.g. [getRversion()].
win_package_dir <- function(cran_root, r_version = getRversion()) {
    assertthat::assert_that(
        inherits(r_version, "R_system_version")
    )

    fs::path(
        cran_root, "bin", "windows", "contrib", paste0(r_version$major, ".", r_version$minor)
    )
}


#' The path of the Mac package folder
#'
#' @inheritParams update_cran
mac_package_dir <- function(cran_root) {
    # TODO: macOS name?
    fs::path(cran_root, "bin", "macosx", "contrib")
}


#' The path of the archive metadata
#'
#' @inheritParams update_cran
#'
#' @return The path of `archive.rds` relative to `cran_root`
archive_metadata_path <- function(cran_root) {
    fs::path(source_package_dir(cran_root), "Meta", "archive.rds")
}


#' The path of the Archive folder
#'
#' @inheritParams update_cran
#'
#' @return The path of the `Archive` folder relative to `cran_root`
archive_path <- function(cran_root) {
    fs::path(source_package_dir(cran_root), "Archive")
}
